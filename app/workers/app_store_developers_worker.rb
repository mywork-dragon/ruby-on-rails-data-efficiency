class AppStoreDevelopersWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :default

  def perform(developer_identifier)
    @developer_identifier = developer_identifier
    get_rows
    seller_name = get_seller_name
    websites = get_websites
    developer = store_developer(seller_name, websites)
    update_ios_apps(developer)
  end

  def get_rows
    @rows = IosAppCurrentSnapshotBackup
      .select(:developer_app_store_identifier, :ios_app_id, :seller_name, :seller_url)
      .where(developer_app_store_identifier: @developer_identifier) +
    IosAppCurrentSnapshot
          .select(:developer_app_store_identifier, :ios_app_id, :seller_name, :seller_url)
          .where(developer_app_store_identifier: @developer_identifier)
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
                  IosDeveloper.create!(
                    identifier: @developer_identifier,
                    name: seller_name
                  )
                rescue ActiveRecord::RecordInvalid
                  IosDeveloper.find_by_identifier!(@developer_identifier)
                end

    join_rows = website_rows.map do |row|
      IosDevelopersWebsite.new(
        ios_developer_id: developer.id,
        website_id: row.id
      )
    end

    IosDevelopersWebsite.import join_rows
    developer
  end

  def store_websites(websites)
    existing = Website.where(url: websites)
    missing = websites - existing.pluck(:url)
    rows = missing.map { |url| Website.new(url: url) }
    Website.import(
      rows,
      synchronize: rows,
      synchronize_keys: [:url]
    )
    existing + rows
  end

  def update_ios_apps(developer)
    ios_app_ids = @rows.map(&:ios_app_id).uniq.compact
    IosApp.where(id: ios_app_ids).update_all(ios_developer_id: developer.id)
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
