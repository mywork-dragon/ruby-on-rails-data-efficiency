class BusinessEntityService

  class << self

    # For Ios linking

    # For new apps every week
    # @author Jason Lew
    def ios_new_apps
      batch = Sidekiq::Batch.new
      batch.description = "ios_new_apps" 
      batch.on(:complete, 'BusinessEntityService#on_complete_ios_new_apps')
  
      previous_week_epf_date = EpfFullFeed.last(2).first.date

      batch.jobs do
        IosApp.select('ios_apps.id, ios_app_snapshots.id as ssid')
          .joins(:newest_ios_app_snapshot).where('ios_apps.released >= ?', previous_week_epf_date).each do |ios_app|
          BusinessEntityIosServiceWorker.perform_async([ios_app.ssid], 'clean_ios')
        end
      end
    end
  end

  def on_complete_ios_new_apps(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'New iOS apps linked to companies.')
  end

  def on_complete_generate_weekly_newest_csv(status, options)
    Slackiq.message("Check the number of new apps. If it's a reasonable number (~15K), run a full app store scrape with `AppStoreSnapshotService.run` on scraper0", webhook_name: :main)
  end

end
