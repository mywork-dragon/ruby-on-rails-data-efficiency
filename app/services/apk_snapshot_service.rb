class ApkSnapshotService
  
  class << self

    def run(notes, size: nil)
      batch = Sidekiq::Batch.new
      batch.description = "scrape #{size} apks from google play"
      batch.on(:complete, "ApkSnapshotService#on_complete")
      batch.jobs do
        j = ApkSnapshotJob.create!(notes: notes, job_type: :mass)
          if size
            raise "Too big" if size > 20e3
            android_apps = AndroidApp.where(display_type: :normal, newest_apk_snapshot_id: nil).joins(:newest_android_app_snapshot).where('android_app_snapshots.price = ? AND android_app_snapshots.released > ?', 0, 1.year.ago).limit(size)
            args = android_apps.map{ |android_app| [j.id, batch.bid, android_app.id, nil] }
            Sidekiq::Client.push_bulk('class' => ApkSnapshotServiceWorker, 'args' => args)
          else
            AndroidApp.where(display_type: :normal, newest_apk_snapshot_id: nil).joins(:newest_android_app_snapshot).where('android_app_snapshots.price = ? AND android_app_snapshots.released > ?', 0, 1.year.ago).find_in_batches(batch_size: 10000).with_index do |the_batch, index|
              li "App #{index*10000}"
              args = the_batch.map{ |android_app| [j.id, batch.bid, android_app.id, nil] }
              Sidekiq::Client.push_bulk('class' => ApkSnapshotServiceWorker, 'args' => args)
            end
          end
          
      end
      #puts Sidekiq::Queue.new('sdk').size
    end

    def run_recently_updated
      batch = Sidekiq::Batch.new
      size = weekly_recently_updated_ids.count
      notes = "Weekly DL (Recently Updated) #{Time.now.strftime("%m/%d/%Y")}"
      set_google_accounts_in_use_false
      j = ApkSnapshotJob.create!(notes: notes, job_type: :mass)
      batch.description = "Weekly Android SDK DL (Recently Released): ~#{size} APKs"
      batch.on(:complete, "ApkSnapshotService#on_complete_run_recently_updated", 'apk_snapshot_job_id' => j.id, 'apps_queued' => size)
      batch_size = 10e3.to_i
      weekly_recently_updated_ids.each_slice(batch_size).with_index do |the_batch, index|
        batch.jobs do
          li "App #{index*batch_size}"
          args = the_batch.map{ |android_app_id| [j.id, batch.bid, android_app_id] }
          Sidekiq::Client.push_bulk('class' => ApkSnapshotServiceWorker, 'args' => args)
        end
      end

      message = "Queued #{size} Android apps for DL ."
      Slackiq.message(message, webhook_name: :main)

      true
    end

    def set_google_accounts_in_use_false
      GoogleAccount.where(blocked: false, scrape_type: :full).each do |ga|
        ga.in_use = false
        ga.save!
      end
    end

    # Temp method to test Google account choosing
    def test_accounts(n = 20)
      n.times do
        ApkSnapshotServiceWorker.perform_async(nil, nil, nil)
      end
    end

    private

    def weekly_recently_updated_ids(limit: 50e3)
      recently_updated_ids = AndroidApp.joins(:newest_android_app_snapshot).where('android_app_snapshots.released > ?', 2.week.ago).order('android_app_snapshots.ratings_all_count DESC').limit(limit).pluck(:id)
    end

  end

  def on_complete(status, options)
    Slackiq.message("ApkSnapshotService complete.", webhook_name: :main)
  end
  
  def on_complete_run_recently_updated(status, options)
    apk_snapshot_job_id = options['apk_snapshot_job_id']

    apps_downloaded = begin 
      ApkSnapshotJob.find(apk_snapshot_job_id).apk_snapshots.where(status: ApkSnapshot.statuses[:success]).count
    rescue => e
      "#{e.message} | #{e.backtrace}"
    end

    apps_queued = options['apps_queued']

    Slackiq.notify(webhook_name: :main, status: status, title: "Weekly Android App Download complete (Recently Updated)", 'Apps Downloaded' => apps_downloaded, 'Apps Queued' => apps_queued, 'apk_snapshot_job_id' => apk_snapshot_job_id)
  end

end