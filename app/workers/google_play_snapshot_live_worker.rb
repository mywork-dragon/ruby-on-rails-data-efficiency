class GooglePlaySnapshotLiveWorker
  include Sidekiq::Worker
  include GooglePlaySnapshotModule
  extend Utils::Workers

  sidekiq_options queue: :google_play_snapshot_live_worker, retry: false

  def perform(android_app_snapshot_job_id, android_app_id, create_developer = false)
    take_snapshot(
      android_app_snapshot_job_id,
      android_app_id,
      create_developer: create_developer,
      scrape_new_similar_apps: false,
      proxy_type: :general
    )
  end

  class << self

    def live_scrape_apps(android_app_ids)
      android_app_ids.each do |id|
        delegate_perform(GooglePlaySnapshotLiveWorker, nil, id)
      end
    end

  end
end
