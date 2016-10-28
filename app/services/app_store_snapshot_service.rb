class AppStoreSnapshotService
  class InvalidDom < RuntimeError; end

  class << self

    def dom_check
      raise InvalidDom unless AppStoreService.dom_valid?
    end

    def run(notes="Full scrape #{Time.now.strftime("%m/%d/%Y")}", automated: false)
      dom_check

      j = IosAppSnapshotJob.create!(notes: notes)

      batch = Sidekiq::Batch.new
      batch.description = "run: #{notes}" 
      batch.on(
        :complete,
        'AppStoreSnapshotService#on_complete_run',
        'automated' => automated
      )

      batch.jobs do
        AppStoreSnapshotQueueWorker.perform_async(:queue_valid, j.id)
      end
    end
    
    def run_app_ids(notes, ios_app_ids)
      dom_check

      batch = Sidekiq::Batch.new
      batch.description = 'run by ios app ids'
      
      j = IosAppSnapshotJob.create!(notes: notes)
      
      batch.jobs do
        AppStoreSnapshotQueueWorker.perform_async(:queue_by_ios_app_ids, j.id, ios_app_ids)
      end
    end
    
    # Last week
    def run_new_apps(notes: 'Running new apps')
      dom_check

      j = IosAppSnapshotJob.create!(notes: notes)
      
      batch = Sidekiq::Batch.new
      batch.description = "run_new_apps: #{notes}" 
      batch.on(:complete, 'AppStoreSnapshotService#on_complete_run_new_apps')
  
      batch.jobs do
        AppStoreSnapshotQueueWorker.perform_async(:queue_new, j.id)
      end
    end
  
  end

  def on_complete_run(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Entire App Store Scrape Completed')
  end
  
  def on_complete_run_new_apps(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'New iOS apps scraped.')

    BusinessEntityService.ios_new_apps # Step 4
  end
end
