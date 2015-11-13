class ApkSnapshotService
  
  class << self
  
    def run(notes)
      j = ApkSnapshotJob.create!(notes: notes)
      AndroidApp.select(:id).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).find_each.with_index do |app, index|
        ApkSnapshotServiceWorker.perform_async(j.id, app.id)
      end
    end

    def run_n(notes, size = 10)

      workers = Sidekiq::Workers.new.any?{ |w| w[2]["queue"] == 'sdk_scraper' }

      clear_accounts()

      if !workers

        batch = Sidekiq::Batch.new
        batch.description = 'scrape n apks from google play'
        batch.on(:complete, self)

        batch.jobs do

          j = ApkSnapshotJob.create!(notes: notes)
          AndroidApp.where(newest_apk_snapshot_id: nil, mobile_priority: 0, display_type: 0).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).limit(size).each.with_index do |app, index|
            li "app #{index}"
            ApkSnapshotServiceWorker.perform_async(j.id, batch.bid, app.id)
          end

        end

      else
        print "WARNING: You cannot continue because there are workers currently running."
      end
    end

    def accounts

      j = ApkSnapshotJob.last

      i = 1
      GoogleAccount.joins(apk_snapshots: :google_account).where('apk_snapshots.apk_snapshot_job_id = ?',j.id).each do |ga|
        snap = ApkSnapshot.where(google_account_id: ga.id, apk_snapshot_job_id: j.id).first
        app = ""
        if snap.status == 'success'
          ap = AndroidPackage.where(apk_snapshot_id: snap.id).count
          app = "| packages : #{ap}"
        end
        
        ai = AndroidApp.find_by_id(snap.android_app_id).app_identifier

        puts "#{i}.) #{ga.id}  |  try : #{snap.try}  |  status : #{snap.status} | name : #{ai} #{app}"
        i += 1
      end

      puts "#{Sidekiq::Workers.new.size} workers"

    end
    
    def clear_accounts
      GoogleAccount.all.each do |ga|
        ga.in_use = false
        ga.flags = 0
        ga.save
      end
    end

    def run_local(notes)

      ActiveRecord::Base.logger.level = 1

      clear_accounts()

      j = ApkSnapshotJob.create!(notes: notes)
      AndroidApp.joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).limit(2).each do |app|
        ApkSnapshotServiceWorker.new.perform(j.id, nil, app.id)
      end
    end


    def single_prod(notes, n = 1)

      j = ApkSnapshotJob.create!(notes: "SINGLE: #{notes}")

      batch = Sidekiq::Batch.new
      batch.jobs do

        AndroidApp.where(taken_down: nil, newest_apk_snapshot_id: nil, mobile_priority: :high).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = 0 AND android_app_snapshots.apk_access_forbidden IS NOT true").limit(n).each do |app|
          ApkSnapshotServiceWorker.new.perform(j.id, batch.bid, app.id)
        end

      end

    end

# AndroidApp.where(taken_down: nil, newest_apk_snapshot_id: nil, mobile_priority: :high).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = 0 AND android_app_snapshots.apk_access_forbidden IS NOT true").limit(100).each{ |app| puts "https://play.google.com/store/apps/details?id=#{app.app_identifier}" }

# This gives you links to every app that threw an exception given a job id
# ApkSnapshotException.where(try: 3, apk_snapshot_job_id: 651).each{ |a| puts "https://play.google.com/store/apps/details?id=#{ApkSnapshot.find(a.apk_snapshot_id).android_app.app_identifier}" }

    def job(id = nil)

      if id.nil?
        j = ApkSnapshotJob.last
      else
        j = ApkSnapshotJob.find(id)
      end

      workers = Sidekiq::Workers.new

      total = j.apk_snapshots.count
      fail = j.apk_snapshots.where(status: 0).count
      success = j.apk_snapshots.where(status: 1).count
      no_response = j.apk_snapshots.where(status: 2).count
      forbidden = j.apk_snapshots.where(status: 3).count
      taken_down = j.apk_snapshots.where(status: 4).count
      could_not_connect = j.apk_snapshots.where(status: 5).count
      timeout = j.apk_snapshots.where(status: 6).count

      progress = ((success + fail).to_f/total)*100
      success_rate = (success.to_f/(success + fail + no_response + forbidden).to_f)*100
      completion_rate = ((success + fail + no_response + forbidden + taken_down + could_not_connect + timeout).to_f / total.to_f)*100

      apk_ga = ApkSnapshot.select(:id).where(['apk_snapshot_job_id = ? and status IS NULL and google_account_id IS NOT NULL', j.id])

      currently_downloading = apk_ga.count

      accounts_in_use = GoogleAccount.where(in_use: true).count

      puts "Successes : #{success}"
      puts "Failures : #{fail}"
      puts "No Response : #{no_response}"
      puts "Forbidden : #{forbidden}"
      puts "Taken Down : #{taken_down}"
      puts "Counldn't Connect : #{could_not_connect}"
      puts "Timeout : #{timeout}"
      puts "Total : #{total}"
      puts "---"
      puts "Success Rate : #{success_rate.round(2)}%"
      puts "Response Rate : #{completion_rate.round(2)}%"
      puts "---"
      puts "Accounts In Use : #{accounts_in_use}"
      puts "Downloading : #{currently_downloading}"
      puts "Workers : #{workers.size}"

    end
  
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :sdk_scraper, status: status, title: 'Scrape Completed!')
  end

  
end