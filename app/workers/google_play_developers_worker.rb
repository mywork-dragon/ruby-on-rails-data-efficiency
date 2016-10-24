class GooglePlayDevelopersWorker
  class NoDeveloperIdentifier < RuntimeError; end
  class NoSnapshot < RuntimeError; end

  class NoSellerUrl; end

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :default

  def perform(method, *args)
    send(method, *args)
  end

  def queue_apps_without_developers
    batch_size = 1_000
    AndroidApp
      .joins(:newest_android_app_snapshot)
      .where(display_type: AndroidApp.display_types.values_at(:normal))
      .where(android_developer_id: nil)
      .find_in_batches(batch_size: batch_size)
      .with_index do |the_batch, index|
        li "App #{index * batch_size}"

        args = the_batch.map { |android_app| [:create_by_android_app_id, android_app.id] }

        SidekiqBatchQueueWorker.perform_async(
          GooglePlayDevelopersWorker.to_s,
          args,
          bid
        )
    end
  end

  def create_by_android_app_id(android_app_id)
    @android_app_id = android_app_id
    @developer = create_developer
    attribute_app_to_developer
    attribute_websites_to_developer
  end

  def app_snapshot
    return @app_snapshot if @app_snapshot
    snapshot = AndroidApp.find(@android_app_id).newest_android_app_snapshot
    raise NoSnapshot unless snapshot
    @app_snapshot = snapshot
  end

  def create_developer
    raise NoDeveloperIdentifier unless app_snapshot.developer_google_play_identifier
    developer = AndroidDeveloper.find_by_identifier(app_snapshot.developer_google_play_identifier)
    return developer if developer

    begin
      AndroidDeveloper.create!(
        identifier: app_snapshot.developer_google_play_identifier,
        name: app_snapshot.seller
      )
    rescue ActiveRecord::RecordNotUnique
      AndroidDeveloper.find_by_identifier!(app_snapshot.developer_google_play_identifier)
    end
  end

  def attribute_app_to_developer
    AndroidApp.find(@android_app_id).update!(android_developer_id: @developer.id)
  end

  def attribute_websites_to_developer
    url = app_snapshot.seller_url
    return NoSellerUrl unless url
    website = begin
                Website.find_or_create_by(url: url)
              rescue ActiveRecord::RecordNotUnique
                Website.find_by_url!(url)
              end
    AndroidDevelopersWebsite.find_or_create_by!(
      android_developer_id: @developer.id,
      website_id: website.id
    )
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Finished creating Google Play Developers')
  end

  class << self

    def queue_apps
      batch = Sidekiq::Batch.new
      batch.description = 'Creating developers for android apps without them'
      batch.on(:complete, 'GooglePlayDevelopersWorker#on_complete')

      batch.jobs do
        GooglePlayDevelopersWorker.perform_async(:queue_apps_without_developers)
      end
    end
  end
end
