class ApkSnapshotService
  
  class << self
  
    def run(notes)
      j = ApkSnapshotJob.create!(notes: notes)
      AndroidApp.select(:id).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).find_each.with_index do |app, index|
        ApkSnapshotServiceWorker.perform_async(j.id, app.id)
      end
    end
  
    def run_n(notes, size = 100)
      workers = Sidekiq::Workers.new
      if workers.size == 0
        j = ApkSnapshotJob.create!(notes: notes)
        AndroidApp.select(:id).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).limit(size).each do |app|
          if Rails.env.production?
            ApkSnapshotServiceWorker.perform_async(j.id, app.id)
          elsif Rails.env.development?
            ApkSnapshotServiceWorker.new.perform(j.id, app.id)
          end
        end
      else
        print "WARNING: You cannot continue because there are #{workers.size} workers currently running."
      end
    end

    def job
      j = ApkSnapshotJob.last

      start = DateTime.now

      while true do
        total = j.apk_snapshots.count
        success = j.apk_snapshots.where(status: 1).count
        fail = j.apk_snapshots.where(status: 0).count

        progress = ((success + fail).to_f/total)*100
        success_rate = (success.to_f/(success + fail).to_f)*100

        apk_ga = ApkSnapshot.select(:google_account_id).where(['apk_snapshot_job_id = ? and status IS NULL and google_account_id IS NOT NULL', j.id])

        currently_downloading = apk_ga.count

        accounts_in_use = GoogleAccount.where(in_use: true).count

        elapsed = DateTime.now - start

        print "Progress : #{(success + fail)} of #{total} - (#{progress.round(2)}%)  |  Success Rate : #{fail} failures, #{success} successes - (#{success_rate.round(2)}% succeeded)  |  Accounts In Use : #{accounts_in_use}  |  Downloading : #{currently_downloading}  |  Time Elapsed : #{elapsed}"

        if progress == 100.0
          puts "\nScrape Completed"
          return false
        else
          print "\r"
        end

        sleep 1
      end

    end

    def fuck
      # ApkSnapshotServiceWorker.perform_async(nil, nil, true) if Rails.env.production?
      j = ApkSnapshotJob.last
      j.is_fucked = true
      j.save!
    end

    def running
      workers = Sidekiq::Workers.new
      workers.size
    end
  
    def about_job(job_id)
      
      j = ApkSnapshotJob.find(job_id)
      
      j.apk_snapshots.each do |apk_snapshot|
        
        puts "APK Snapshot: #{apk_snapshot.inspect}"
        puts "App Identifier: #{apk_snapshot.android_app.app_identifier}"
        puts ''
        
        puts 'AndroidPackages'
        puts '---------------'
        
        apk_snapshot.android_packages.each do |android_package|
          puts android_package.package_name
        end
        
        puts ''
        puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
      end
      
    end
  
  end
  
end