class ApkSnapshotService
  
  class << self
  
    def run(notes)
      
      j = ApkSnapshotJob.create!(notes: notes)
      
      AndroidApp.select(:id).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).find_each.with_index do |app, index|
        ApkSnapshotServiceWorker.perform_async(j.id, app.id)
      end
      
    end
  
    def run_n(notes, size = 100)
      j = ApkSnapshotJob.create!(notes: notes)
      
      AndroidApp.select(:id).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).limit(size).each do |app|

        if Rails.env.production?
          ApkSnapshotServiceWorker.perform_async(j.id, app.id)
        elsif Rails.env.development?
          ApkSnapshotServiceWorker.new.perform(j.id, app.id)
        end

      end
    end
    
    def run_common_apps(notes)
      
      j = ApkSnapshotJob.create!(notes: notes)
      
      app_identifiers = %w(
        com.instagram.android
        com.pinterest
        com.snapchat.android
        com.twitter.android
        com.skype.raider
        com.facebook.orca
      )
      
      app_identifiers.each do |ai|
        aa = AndroidApp.find_by_app_identifier(ai)
        ApkSnapshotServiceWorker.perform_async(j.id, aa.id)
        # ApkSnapshotServiceWorker.new.perform(j.id, aa.id)
      end
      
    end

    def retry_failed_apps(job_id)
      j = ApkSnapshotJob.find(job_id)
      j.apk_snapshots.where(status: 0).find_each do |app|
        ApkSnapshotServiceWorker.perform_async(j.id, app.android_app_id)
      end
    end

    def job
      j = ApkSnapshotJob.last

      while true do
        total = j.apk_snapshots.count
        success = j.apk_snapshots.where(status: 1).count
        fail = j.apk_snapshots.where(status: 0).count

        progress = ((success + fail).to_f/total)*100
        success_rate = (success.to_f/(success + fail).to_f)*100

        apk_ga = ApkSnapshot.select(:google_account_id).where(['apk_snapshot_job_id = ? and status IS NULL and google_account_id IS NOT NULL', j.id])

        currently_downloading = apk_ga.count

        accounts_in_use = GoogleAccount.where(in_use: true).count

        print "Progress : #{(success + fail)} of #{total} - (#{progress.round(2)}%)  |  Success Rate : #{fail} failures, #{success} successes - (#{success_rate.round(2)}% succeeded)  |  Accounts In Use : #{accounts_in_use}  |  Currently Downloading : #{currently_downloading}"

        if progress == 100.0
          puts "\nScrape Complete"
          return false
        else
          print "\r"
        end

        sleep 1
      end

    end

    def fuck
      j = ApkSnapshotJob.last
      j.is_fucked = true
      j.save!
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