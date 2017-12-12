class GooglePlaySnapshotLiveWorker
  include Sidekiq::Worker
  include GooglePlaySnapshotModule

  sidekiq_options queue: :live, retry: false

  def proxy_type
    :general
  end

  # no-op
  def scrape_new_similar_apps(similar_apps)
    nil
  end

  class << self

    def live_scrape_apps(android_app_ids)
      android_app_ids.each do |id|
        GooglePlaySnapshotLiveWorker.perform_async(nil, id)
      end
    end

  end
end
