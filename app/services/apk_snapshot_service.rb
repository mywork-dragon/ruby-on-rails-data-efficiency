class ApkSnapshotService
  
  class << self
  
    def run(notes)
      
      j = ApkSnapshotJob.create!(notes: notes)
      
      AndroidApp.select(:id).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).find_each.with_index do |app, index|
        ApkSnapshotServiceWorker.perform_async(j.id, app.id)
      end
      
    end
  
    def run_n(notes, size: 100)
      j = ApkSnapshotJob.create!(notes: notes)
      
      AndroidApp.select(:id).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).limit(size).each_with_index do |app, index|
        li "App #{index}"
        ApkSnapshotServiceWorker.perform_async(j.id, app.id)
      end
    end
  
    # For testing
    def run_test(notes)
      
      j = ApkSnapshotJob.create!(notes: notes)
      
      aa = AndroidApp.find_by_app_identifier('com.pinterest')
      # ApkSnapshotServiceWorker.perform_async(j.id, aa.id)
      ApkSnapshotServiceWorker.new.perform(j.id, aa.id)
      
    end
    
    def run_common_apps(notes)
      
      j = ApkSnapshotJob.create!(notes: notes)
      
      app_identifiers = %w(
        com.instagram.android
        com.pinterest
      )

        # com.snapchat.android
        # com.twitter.android
        # com.skype.raider
        # com.facebook.orca
      
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

    def job_progress(job_id)
      j = ApkSnapshotJob.find(job_id)

      while true do
        total = j.apk_snapshots.count
        success = j.apk_snapshots.where(status: 1).count
        fail = j.apk_snapshots.where(status: 0).count

        progress = ((success + fail).to_f/total)*100
        success_rate = (success.to_f/(success + fail).to_f)*100

        print "Progress : #{progress.round(2)}%  |  Success Rate : #{success_rate.round(2)}%"
        print "\r"

        return false if progress == 100.0

        sleep 1
      end

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


# ApkSnapshotService.run_common_apps('')
# ApkSnapshotService.job_progress(34)