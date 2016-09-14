class GooglePlaySnapshotLiveWorker
  include Sidekiq::Worker
  include GooglePlaySnapshotModule

  sidekiq_options queue: :sdk_live_scan, retry: false

  def proxy_type
    :all_static
  end

  # no-op
  def scrape_new_similar_apps(similar_apps)
    nil
  end

  class << self
    def test_successful
      a = AndroidApp.find_or_create_by!(app_identifier: 'com.ubercab')
      new.perform(-1, a.id)
    end

    def test_missing
      a = AndroidApp.find_or_create_by!(app_identifier: 'com.kittyplay.ex')
      new.perform(-1, a.id)
    end

    def test_foreign
      a = AndroidApp.find_or_create_by!(app_identifier: 'com.opera.mini.android')
      new.perform(-1, a.id)
    end
  end
end
