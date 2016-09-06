class ItunesTosWorker
  include Sidekiq::Worker

  sidekiq_options queue: :sdk_scraper_live_scan, retry: false

  def perform(method, *args)
    send(method, *args)
  end

  def check_app_store(app_store_id)
    updated_date = ItunesTos.itunes_updated_date(app_store_id: app_store_id)
    newest_tos_snapshot = AppStore.find(app_store_id).newest_tos_snapshot

    if newest_tos_snapshot.blank?
      save_snapshot(app_store_id, updated_date)
    elsif newest_tos_snapshot.last_updated_date < updated_date
      save_snapshot(app_store_id, updated_date)
      disable_app_store(app_store_id)
      trigger_alert(app_store_id, updated_date)
    else
      newest_tos_snapshot.touch_valid_date
    end
  end

  def save_snapshot(app_store_id, updated_date)
    AppStoreTosSnapshot.create!(
      app_store_id: app_store_id,
      last_updated_date: updated_date,
    )
  end

  def disable_app_store(app_store_id)
    AppStore.find(app_store_id).update!(
      tos_valid: false
    )
  end

  def trigger_alert(app_store_id, updated_date)
    puts 'RIP'
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
