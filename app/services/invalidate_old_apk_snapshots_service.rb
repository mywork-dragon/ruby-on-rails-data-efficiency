class InvalidateOldApkSnapshotsService

  class << self

    def run
      batch = Sidekiq::Batch.new
      batch.description = "InvalidateOldApkSnapshotsServices"
      batch.on(:complete, "InvalidateOldApkSnapshotsService#on_complete")
      batch_size = 10e3.to_i
      AndroidApp.where.not(newest_apk_snapshot: nil).find_in_batches(batch_size: batch_size).with_index do |the_batch, index|
        batch.jobs do
          li "App #{index*batch_size}"
          args = the_batch.map{ |android_app| [android_app.id] }
          Sidekiq::Client.push_bulk('class' => InvalidateOldApkSnapshotsWorker, 'args' => args)
        end
      end
    end

  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'InvalidateOldApkSnapshotsService complete')
  end

end