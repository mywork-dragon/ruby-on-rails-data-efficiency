class AndroidNewestApkSnapshotService
  class << self
    def update_all_pointers

      batch = Sidekiq::Batch.new
      batch.description = "Updating Android app newest APK snapshot pointers"
      batch.on(:complete, 'AndroidNewestApkSnapshotService#on_complete')

      AndroidApp.distinct.joins(:apk_snapshots).find_in_batches(batch_size: 1000).with_index do |app_batch, index|
        puts "Batch #{index}" if index % 10 == 0
        batch.jobs do
          args = app_batch.map{ |android_app| [android_app.id] }
          Sidekiq::Client.push_bulk('class' => AndroidAppNewestPointerWorker, 'args' => args)
        end        
      end

      puts "Done queueing"
    end
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'updated newest APK snapshot pointers')
  end

end