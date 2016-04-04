class ActivityService

  class << self

    def backfill_ios_apps
      batch = Sidekiq::Batch.new
      batch.description = "Create ios sdk activities"
      batch.on(:complete, "ActivityService#on_complete")
      IosApp.find_in_batches(batch_size: 10000).with_index do |the_batch, index|
        batch.jobs do
          li "App #{index*10000}"
          args = the_batch.map{ |ios_app| [:log_ios_sdks, ios_app.id] }
          Sidekiq::Client.push_bulk('class' => ActivityWorker, 'args' => args)
        end
      end
    end

    def backfill_android_apps
      batch = Sidekiq::Batch.new
      batch.description = "Create android sdk activities"
      batch.on(:complete, "ActivityService#on_complete")
      AndroidApp.find_in_batches(batch_size: 10000).with_index do |the_batch, index|
        batch.jobs do
          li "App #{index*10000}"
          args = the_batch.map{ |android_app| [:log_android_sdks, android_app.id] }
          Sidekiq::Client.push_bulk('class' => ActivityWorker, 'args' => args)
        end
      end
    end

    def fix_ios_apps
      (IosSdk.joins(:inbound_sdks).to_a + IosSdk.joins(:outbound_sdk).to_a).uniq.map{|sdk| sdk.get_current_apps.pluck(:id)}.flatten.uniq.each do |id|
        ActivityWorker.perform_async(:log_ios_sdks, id)
      end
    end
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Created activity objects')
  end
end