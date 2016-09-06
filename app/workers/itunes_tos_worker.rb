class ItunesTosWorker
  include Sidekiq::Worker

  sidekiq_options queue: :sdk_scraper_live_scan, retry: false

  def perform(method, *args)
    send(method, *args)
  end

  def check_app_store(app_store_id)
  end

  def on_complete_check_app_stores(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Checked iTunes TOS for enabled app stores')
  end

  class << self
    def check_app_stores
      batch = Sidekiq::Batch.new
      batch.description = 'ItunesTosWorker.check_app_stores'
      batch.on(:complete, 'ItunesTosWorker#on_complete_check_app_stores')

      batch.jobs do
        AppStore.where(enabled: true).each do |app_store|
          ItunesTosWorker.perform_async(app_store.id)
        end
      end
    end
  end
end
