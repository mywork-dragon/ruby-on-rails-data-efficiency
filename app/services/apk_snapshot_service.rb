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

      # I should make sure that all processes are killed before I begin

      if workers.size == 0
        j = ApkSnapshotJob.create!(notes: notes)
        AndroidApp.where(taken_down: nil).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).limit(size).each do |app|
          ApkSnapshotServiceWorker.perform_async(j.id, app.id)
        end
      else
        print "WARNING: You cannot continue because there are #{workers.size} workers currently running."
      end
    end

    def run_dummy(notes)

      workers = Sidekiq::Workers.new
      if workers.size == 0
        j = ApkSnapshotJob.create!(notes: notes)
        apps = [1,2,3,4,5,6,7,8,9,11]
        apps.each do |app|
          ApkSnapshotServiceWorker.perform_async(j.id, app)
          # ApkSnapshotServiceWorker.new.perform(j.id, app)
        end
      else
        print "WARNING: You cannot continue because there are #{workers.size} workers currently running."
      end

    end

    def job
      j = ApkSnapshotJob.last

      start = Time.now

      workers = Sidekiq::Workers.new

      while true do
        total = j.apk_snapshots.count
        success = j.apk_snapshots.where(status: 1).count
        fail = j.apk_snapshots.where(status: 0).count

        progress = ((success + fail).to_f/total)*100
        success_rate = (success.to_f/(success + fail).to_f)*100

        apk_ga = ApkSnapshot.select(:id).where(['apk_snapshot_job_id = ? and status IS NULL and google_account_id IS NOT NULL', j.id])

        currently_downloading = apk_ga.count

        accounts_in_use = GoogleAccount.where(in_use: true).count

        elapsed = (Time.now - start).to_i

        print "Progress : #{(success + fail)} of #{total} - (#{progress.round(2)}%)  |  Success Rate : #{fail} failures, #{success} successes - (#{success_rate.round(2)}% succeeded)  |  Accounts In Use : #{accounts_in_use}  |  Downloading : #{currently_downloading}  |  Workers : #{workers.size} \r"

        if progress == 100.0
          puts "\n\nScrape Completed"
          return false
        end

        sleep 1
      end

    end

    def clear_accounts
      GoogleAccount.all.each do |ga|
        ga.in_use = false
        ga.save
      end
    end

    # def fuck
    #   # ApkSnapshotServiceWorker.perform_async(nil, nil, true) if Rails.env.production?
    #   j = ApkSnapshotJob.last
    #   j.is_fucked = true
    #   j.save!
    # end

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