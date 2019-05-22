# Used in AppStoreSnapshotService

class AppStoreSnapshotQueueWorker
  include Sidekiq::Worker

  sidekiq_options queue: :ios_web_scrape, retry: false

  def perform(method, *args)
    send(method, *args)
  end

  def queue_worker
    ids = IosApp.select(:id)
      .where(@query)
      .pluck(:id)

    ids.each_slice(1_000) do |slice|
      args = slice.map { |ios_app_id| [@ios_app_snapshot_job_id, ios_app_id] }

      Sidekiq::Client.push_bulk(
        'class' => AppStoreSnapshotServiceWorker,
        'args' => args)
    end
  end

  def queue_valid(ios_app_snapshot_job_id)
    Slackiq.message('Starting to queue App Store apps', webhook_name: :main)
    @ios_app_snapshot_job_id = ios_app_snapshot_job_id
    @query = { display_type: IosApp.display_types.values_at(:paid, :normal, :device_incompatible) }
    queue_worker
    Slackiq.message('Finished queueing App Store apps', webhook_name: :main)
  end

  def queue_new(ios_app_snapshot_job_id)
    Slackiq.message('Queueing new App Store apps', webhook_name: :main)
    @ios_app_snapshot_job_id = ios_app_snapshot_job_id
    previous_week_epf_date = EpfFullFeed.last(2).first.date
    @query = ['released >= ?', previous_week_epf_date]
    queue_worker
    Slackiq.message('Finished queueing new App Store apps', webhook_name: :main)
  end

  def queue_by_ios_app_ids(ios_app_snapshot_job_id, ios_app_ids)
    @ios_app_snapshot_job_id = ios_app_snapshot_job_id
    @query = { id: ios_app_ids }
    queue_worker
  end
end
