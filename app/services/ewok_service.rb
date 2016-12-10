# Service for the Ewok Chrome Extension
class EwokService

  STAGING = false
  KEY = 'db5be718bbaf446cf24e39d61c82e9c7'

  class << self

    def correct_key?(key)
      key == KEY
    end

    def app_id_and_store(url)
      if md = url.match(/itunes\.apple\.com\/.*id(\d+)/)
        app_identifier = md.captures.first
        ios_app = IosApp.find_by_app_identifier(app_identifier)
        raise AppNotInDb.new(store: :ios, app_identifier: app_identifier) unless ios_app
        return {id: ios_app.id, store: :ios} 
      elsif md = url.match(/play.google.com\/store\/apps\/details\?id=([^&]*)/)
        app_identifier = md.captures.first
        android_app = AndroidApp.find_by_app_identifier(app_identifier)
        raise AppNotInDb.new(store: :android, app_identifier: app_identifier) unless android_app  
        return {id: android_app.id, store: :android}
      end
      nil
    end



    def app_url(url)
      ais = app_id_and_store(url)
      
      return nil if ais.nil?

      id = ais[:id]
      store = ais[:store]

      domain = STAGING ? 'staging.mightysignal.com' : 'mightysignal.com'

      if store == :ios
        ret = "https://#{domain}/app/app#/app/ios/#{id}"
      elsif store == :android
        ret = "https://#{domain}/app/app#/app/android/#{id}" 
      end

      ret
    end

    def scrape_async(app_identifier:, store:)
      method = if store == :ios
        :scrape_ios
      elsif store == :android
        :scrape_android
      end

      batch = Sidekiq::Batch.new
      batch.description = "New app Ewok scrape (#{store}): #{app_identifier}" 
      batch.on(:complete, 'EwokService#on_complete_scrape_async')

      batch.jobs do 
        EwokScrapeWorker.perform_async(method, app_identifier)
      end
    end

    def scrape_international_async(app_identifier:, store:)
      method = :scrape_ios_international

      batch = Sidekiq::Batch.new
      batch.description = "New app Ewok international scrape (#{store}): #{app_identifier}" 
      batch.on(
        :complete,
        'EwokService#on_complete_scrape_international_async',
        'app_identifier' => app_identifier
      )

      batch.jobs do 
        EwokScrapeWorker.perform_async(method, app_identifier)
      end
    end

  end

  def on_complete_scrape_async(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Ewok added a new app.')
  end

  def on_complete_scrape_international_async(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Ewok completed international scraping')

    if status.failures.zero?
      # create developers. not essential, so will run on scraper queue. If fail, will get picked up during next scrape
      AppStoreInternationalDevelopersQueueWorker.perform_async(:run_by_app_identifier, options['app_identifier'].to_i)
    end
  end
  

  class AppNotInDb < StandardError
    attr_reader :store
    attr_reader :app_identifier

    def initialize(message = "The app is not in the DB.", store:, app_identifier:)
      @store = store
      @app_identifier = app_identifier
      super("The app with identifier #{app_identifier} is not in the #{store.to_s} store.")
    end
  end

end
