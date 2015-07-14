class ApkSnapshotService
  
  class << self
  
    def run(notes)
      j = ApkSnapshotJob.create!(notes: notes)
      AndroidApp.select(:id).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).find_each.with_index do |app, index|
        ApkSnapshotServiceWorker.perform_async(j.id, app.id)
      end
    end

    def run_n(notes, size = 10)
      workers = Sidekiq::Workers.new

      clear_accounts()

      if workers.size == 0
        j = ApkSnapshotJob.create!(notes: notes)
        AndroidApp.where(taken_down: nil).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).limit(size).each.with_index do |app, index|
          li "app #{index}"
          ApkSnapshotServiceWorker.perform_async(j.id, app.id)
        end
      else
        print "WARNING: You cannot continue because there are #{workers.size} workers currently running."
      end
    end

    def accounts

      j = ApkSnapshotJob.last

      i = 1
      GoogleAccount.joins(apk_snapshots: :google_account).where('apk_snapshots.apk_snapshot_job_id = ?',j.id).each do |ga|
        snap = ApkSnapshot.where(google_account_id: ga.id, apk_snapshot_job_id: j.id).first
        app = ""
        if snap.status == 'success'
          ai = AndroidApp.find_by_id(snap.android_app_id).app_identifier
          ap = AndroidPackage.where(apk_snapshot_id: snap.id).count
          app = "| name : #{ai} | packages : #{ap}"
        end
        puts "#{i}.) #{ga.id}  |  try : #{snap.try}  |  status : #{snap.status} #{app}"
        i += 1
      end

      puts "#{Sidekiq::Workers.new.size} workers"

    end

    def clear_accounts
      GoogleAccount.all.each do |ga|
        ga.in_use = false
        ga.save
      end
    end

    def run_local(notes)

      ActiveRecord::Base.logger.level = 1

      clear_accounts()

      j = ApkSnapshotJob.create!(notes: notes)
      AndroidApp.where(taken_down: nil).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).limit(2).each.with_index do |app, index|
        # li "app #{index}"
        ApkSnapshotServiceWorker.new.perform(j.id, app.id)
      end
    end


    # def job
    #   j = ApkSnapshotJob.last

    #   workers = Sidekiq::Workers.new

    #   while true do
    #     total = j.apk_snapshots.count
    #     success = j.apk_snapshots.where(status: 1).count
    #     fail = j.apk_snapshots.where(status: 0).count

    #     progress = ((success + fail).to_f/total)*100
    #     success_rate = (success.to_f/(success + fail).to_f)*100

    #     apk_ga = ApkSnapshot.select(:id).where(['apk_snapshot_job_id = ? and status IS NULL and google_account_id IS NOT NULL', j.id])

    #     currently_downloading = apk_ga.count

    #     accounts_in_use = GoogleAccount.where(in_use: true).count

    #     print "Progress : #{(success + fail)} of #{total} - (#{progress.round(2)}%)  |  Success Rate : #{fail} failures, #{success} successes - (#{success_rate.round(2)}% succeeded)  |  Accounts In Use : #{accounts_in_use}  |  Downloading : #{currently_downloading}  |  Workers : #{workers.size} \r"

    #     if progress == 100.0
    #       puts "\n\nScrape Completed"
    #       return false
    #     end

    #     sleep 1
    #   end

    # end
  
    # def about_job(job_id)
      
    #   j = ApkSnapshotJob.find(job_id)
      
    #   j.apk_snapshots.each do |apk_snapshot|
        
    #     puts "APK Snapshot: #{apk_snapshot.inspect}"
    #     puts "App Identifier: #{apk_snapshot.android_app.app_identifier}"
    #     puts ''
        
    #     puts 'AndroidPackages'
    #     puts '---------------'
        
    #     apk_snapshot.android_packages.each do |android_package|
    #       puts android_package.package_name
    #     end
        
    #     puts ''
    #     puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    #   end
      
    # end
  
  end
  
end