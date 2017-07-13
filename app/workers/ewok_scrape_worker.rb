class EwokScrapeWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :ewok

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def get_ios_app(app_identifier)
    app = IosApp.find_by_app_identifier(app_identifier)
    app || IosApp.create!(app_identifier: app_identifier, source: :ewok)
  rescue ActiveRecord::RecordNotUnique
    IosApp.find_by_app_identifier!(app_identifier)
  end

  def scrape_ios(app_identifier)

    a = AppStoreService.attributes(app_identifier)
    raise AttributesBlank if a.blank?

    ios_app = get_ios_app(app_identifier)
    AppStoreSnapshotServiceWorker.new.perform(nil, ios_app.id)
  end

  def scrape_android(app_identifier)
    android_app = AndroidApp.create!(app_identifier: app_identifier)
    android_app_id = android_app.id
    GooglePlaySnapshotLiveWorker.new.perform(nil, android_app_id)
    GooglePlayDevelopersWorker.new.create_by_android_app_id(android_app_id)
  end

  def scrape_ios_international(app_identifier)
    ios_app = get_ios_app(app_identifier)

    batch.jobs do
      AppStoreInternationalService.scrape_ios_apps(
        [ios_app.id],
        live: true,
        notes: "Ewok scrape ios app #{ios_app.id}: #{app_identifier}"
      )
    end

  end

  class AttributesBlank< StandardError
    def initialize(message = "The attributes are blank.")
      super
    end
  end

  class << self

    def test
      return 'dont do this' if Rails.env.production?
      app_identifier = 389801252
      # IosApp.where(app_identifier: app_identifier).delete_all
      new.scrape_ios_international(app_identifier)
    end
  end
end
