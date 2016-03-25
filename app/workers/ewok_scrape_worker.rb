class EwokScrapeWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :sdk_live_scan

  RETRES = 2

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def scrape_ios(app_identifier)
    tries ||= RETRIES + 1

    a = AppStoreService.attributes(app_identifier)
    raise AttributesBlank if a.blank?

    ios_app = IosApp.create!(app_identifier: app_identifier)
    AppStoreSnapshotServiceWorker.new.perform(nil, ios_app.id)
  rescue => e
    retry unless (tries -= 1).zero?
  end

  def scrape_android(app_identifier)
    tries ||= RETRIES + 1

    a = GooglePlayService.attributes(app_identifier)
    raise AttributesBlank if a.blank?

    android_app = AndroidApp.create!(app_identifier: app_identifier)
    GooglePlaySnapshotServiceWorker.new.perform(nil, android_app.id)
  rescue => e
    retry unless (tries -= 1).zero?
  end


  class AttributesBlank< StandardError
    def initialize(message = "The attributes are blank.")
      super
    end
  end
end