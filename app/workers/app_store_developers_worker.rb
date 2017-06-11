class AppStoreDevelopersWorker
  class NoDeveloperIdentifier < RuntimeError; end

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :developer_creation

  def perform(method, *args)
    send(method, *args)
  end

  def create_by_ios_app_id(ios_app_id, ensure_required: true)
    @ios_app_id = ios_app_id
    return if ensure_required && already_populated?
    developer_identifier = find_developer_app_store_identifier
    create_by_developer_identifier(developer_identifier)
  end

  def create_by_developer_identifier(developer_identifier)
    @developer_identifier = developer_identifier
    rows_by_developer_identifier
    seller_name = get_seller_name
    websites = get_websites
    developer = store_developer(seller_name, websites)
    update_ios_apps(developer)
  end

  def already_populated?
    !!IosApp.find(@ios_app_id).ios_developer_id
  end

  def rows_by_developer_identifier
    @rows = IosAppCurrentSnapshot
              .select(:developer_app_store_identifier, :ios_app_id, :seller_name, :seller_url)
              .where("developer_app_store_identifier = ? and latest = ?", @developer_identifier, true).to_a
  end

  def find_developer_app_store_identifier
    current_snapshot = IosAppCurrentSnapshot.where("ios_app_id = ? and latest = ?", @ios_app_id, true).limit(1).take
    return current_snapshot.developer_app_store_identifier if current_snapshot
    raise NoDeveloperIdentifier
  end

  def get_seller_name
    seller_names = @rows.map(&:seller_name).uniq.compact
    puts "More than 1 seller name for #{@developer_identifier}" if seller_names.count > 1
    seller_names.first
  end

  def get_websites
    @rows.map(&:seller_url).uniq.compact
  end

  def store_developer(seller_name, websites)
    website_rows = store_websites(websites)
    developer = begin
                  IosDeveloper.find_or_create_by!(
                    identifier: @developer_identifier
                  )
                rescue ActiveRecord::RecordNotUnique
                  IosDeveloper.find_by_identifier!(@developer_identifier)
                end
    developer.update!(name: seller_name) if seller_name != developer.name
    store_ios_developer_websites(website_rows, developer)
    developer
  end

  def store_ios_developer_websites(website_rows, developer)
    existingJoinRows = IosDevelopersWebsite
      .where(ios_developer_id: developer.id)
      .where(website_id: website_rows.map(&:id))

    join_rows = website_rows.reject do |website_row|
      existingJoinRows.find {|joinRow| joinRow.ios_developer_id == developer.id && joinRow.website_id == website_row.id }
    end.map do |new_website_row|
      dev_website = IosDevelopersWebsite.new(
        ios_developer_id: developer.id,
        website_id: new_website_row.id
      )
      dev_website.set_is_valid
      dev_website
    end

    IosDevelopersWebsite.import join_rows
  end

  def store_websites(websites)
    existing = Website.where(url: websites).to_a # convert 'existing' to array execute query now or else we'll return duplicates
    missing = websites - existing.map(&:url)
    rows = missing.map { |url| Website.new(url: url) }
    rows.each { |row| row.run_callbacks(:create) { false } } # hook in before_create callbacks
    Website.import(
      rows,
      synchronize: rows,
      synchronize_keys: [:url]
    )
    existing + rows
  end

  def update_ios_apps(developer)
    existing_ios_app_ids = developer.ios_apps.pluck(:id).uniq
    ios_app_ids = @rows.map(&:ios_app_id).uniq.compact
    IosApp.where(id: ios_app_ids - existing_ios_app_ids).update_all(ios_developer_id: developer.id)
  end

  class << self
    
    def test
      ios_apps = [1, 2, 3, 4].map { |app_identifier| IosApp.find_or_create_by!(app_identifier: app_identifier) }
      rows = ios_apps.map do |ios_app|
        IosAppCurrentSnapshotBackup.new(
          ios_app_id: ios_app.id,
          developer_app_store_identifier: 1,
          seller_name: ios_app.app_identifier.to_s,
          seller_url: "http://www.#{ios_app.app_identifier.to_s}.com"
        )
      end

      IosAppCurrentSnapshotBackup.import(
        rows,
        synchronize: rows,
        synchronize_keys: [:ios_app_id]
      )

      IosDeveloper.delete_all
      new.perform(rows.first.developer_app_store_identifier)
    end
  end
end
