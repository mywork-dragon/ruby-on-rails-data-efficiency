class GooglePlaySnapshotLiveWorker
  include Sidekiq::Worker
  include GooglePlaySnapshotModule

  sidekiq_options queue: :sdk_live_scan, retry: false

  def proxy_type
    :general
  end

  # no-op
  def scrape_similar_apps
    nil
  end

  class << self
    def test
      a = AndroidApp.find_or_create_by!(app_identifier: 'com.ubercab')
      new.perform(-1, a.id)
    end
  end
end
