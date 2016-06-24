class AppStoreInternationalService

  class << self
    def run_snapshots(notes: nil, automated: false)
      batch = Sidekiq::Batch.new
      batch.description = "AppStoreInternationalService.run_snapshots" 
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_snapshots',
        'automated' => automated
      )

      batch.jobs do
        AppStoreInternationalSnapshotQueueWorker.perform_async
      end
    end

    def run_scaling_factors(automated: false)
      batch = Sidekiq::Batch.new
      batch.description = "AppStoreInternationalService#run_scaling_factors" 
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_scaling_factors',
        'automated' => automated
      )

      Slackiq.message("Starting to calculate scaling factors", webhook_name: :main)

      batch.jobs do
        AppStore.where(enabled: true).each do |app_store|
          AppStoreInternationalScalingFactorsWorker.perform_async(app_store.id)
        end
      end
    end

    def run_user_bases(automated: false)
      batch = Sidekiq::Batch.new
      batch.description = 'AppStoreInternationalService#run_user_bases'
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_user_bases',
        'automated' => automated
      )

      Slackiq.message("Starting to populate user bases", webhook_name: :main)

      batch.jobs do
        AppStore.where(enabled: true).each do |app_store|
          AppStoreInternationalUserBaseWorker.perform_async(app_store.id)
        end
      end
    end

    def run_app_store_linking(automated: false)
      batch = Sidekiq::Batch.new
      batch.description = 'AppStoreInternationalService#run_app_store_linking'
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_app_store_linking',
        'automated' => automated
      )

      Slackiq.message("Starting to link app stores to apps", webhook_name: :main)

      batch.jobs do
        AppStoreInternationalAppLinkWorker.perform_async
      end
    end
  end

  def on_complete_snapshots(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Entire App Store Scrape (international) completed')

    if options['automated']
      self.class.run_scaling_factors(automated: true)
    end
  end

  def on_complete_scaling_factors(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Calculated scaling factors for app stores')

    if options['automated']
      self.class.run_user_bases(automated: true)
    end
  end

  def on_complete_user_bases(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Populated user bases')

    if options['automated']
      self.class.run_app_store_linking(automated: true)
    end
  end

  def on_complete_app_store_linking(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Populated app links')
  end

end
