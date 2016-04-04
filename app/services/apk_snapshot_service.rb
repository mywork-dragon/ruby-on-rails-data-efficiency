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

    def run_weekly
      batch = Sidekiq::Batch.new
      size = weekly_apps.count
      notes = "Weekly DL #{Time.now.strftime("%m/%d/%Y")}"
      j = ApkSnapshotJob.create!(notes: notes, job_type: :mass)
      batch.description = "Weekly Android SDK DL: ~#{size} APKs"
      batch.on(:complete, "ApkSnapshotService#on_complete_run_weekly", 'apk_snapshot_job_id' => j.id, 'apps_queued' => size)
      batch_size = 10e3.to_i
      weekly_apps.find_in_batches(batch_size: batch_size).with_index do |the_batch, index|
        batch.jobs do
          li "App #{index*batch_size}"
          args = the_batch.map{ |android_app| [j.id, batch.bid, android_app.id, nil] }
          Sidekiq::Client.push_bulk('class' => ApkSnapshotServiceWorker, 'args' => args)
        end  
      end

      message = "Queued #{size} Android apps for DL."
      Slackiq.message(message, webhook_name: :main)

      true
    end

    # Temp method to test Google account choosing
    def test_accounts(n = 20)
      n.times do
        ApkSnapshotServiceWorker.perform_async(nil, nil, nil)
      end
    end

    private

    def weekly_apps
      AndroidApp.where(display_type: :normal, newest_apk_snapshot_id: nil).joins(:newest_android_app_snapshot).where('android_app_snapshots.price = ? AND android_app_snapshots.released > ?', 0, 2.weeks.ago)
    end
    
    # def daemon(command)
    #   ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address()
    #   if ip == '172.31.38.183'
    #     `ruby 'app/services/sidekiq_service_controller.rb' #{command}`
    #   else
    #     puts "You can only run the Sidekiq monitoring daemon on sdk_scraper1."
    #   end
    # end

  end

  def on_complete(status, options)
    Slackiq.message("ApkSnapshotService complete.", webhook_name: :main)
  end

  def on_complete_run_weekly(status, options)
    apk_snapshot_job_id = options['apk_snapshot_job_id']

    apps_downloaded = begin 
      ApkSnapshotJob.find(apk_snapshot_job_id).apk_snapshots.where(status: ApkSnapshot.statuses[:success]).count
    rescue => e
      "#{e.message} | #{e.backtrace}"
    end

    apps_queued = options['apps_queued']

    Slackiq.notify(webhook_name: :main, status: status, title: "Weekly Android App Download complete", 'Apps Downloaded' => apps_downloaded, 'Apps Queued' => apps_queued, 'apk_snapshot_job_id' => apk_snapshot_job_id)
  end
  
end