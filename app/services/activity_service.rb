class ActivityService

  class << self

    def backfill_ios_apps
      batch = Sidekiq::Batch.new
      batch.description = "Create ios sdk activities"
      batch.on(:complete, "ActivityService#on_complete")
      IosApp.find_in_batches(batch_size: 10000).with_index do |the_batch, index|
        batch.jobs do
          li "App #{index*10000}"
          args = the_batch.map{ |ios_app| [:log_ios_sdks, ios_app.id, true] }
          Sidekiq::Client.push_bulk('class' => ActivityWorker, 'args' => args)
        end
      end
    end
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Created activity objects')
  end
end