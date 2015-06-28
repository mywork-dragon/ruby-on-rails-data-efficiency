class ApkSnapshotServiceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false
  
  MAX_TRIES = 3

  ActiveRecord::Base.logger.level = 1 if Rails.env.development?
  
  def perform(apk_snapshot_job_id, app_id)
    download_apk(apk_snapshot_job_id, app_id)
  end
  
  def apk_file_name(app_identifier)
    if Rails.env.production?
      file_name = "/mnt/apk_files/" + app_identifier + ".apk"
    elsif Rails.env.development?
      file_name = "../apk_files/" + app_identifier + ".apk"
    end
    file_name
  end

  def download_apk(apk_snapshot_job_id, android_app_id)

    apk_snap = ApkSnapshot.create(android_app_id: android_app_id, apk_snapshot_job_id: apk_snapshot_job_id)

    @try = 0

    begin

      best_account, proxy = optimal_account(android_app_id, apk_snapshot_job_id)

      apk_snap.google_account_id = best_account.id
      apk_snap.save!

      email = best_account.email
      password = best_account.password
      android_identifier = best_account.android_identifier

      start_time = Time.now()
      ApkDownloader.configure do |config|
        config.email = email
        config.password = password
        config.android_id = android_identifier
        config.proxy = proxy
      end


      apps = {
        "1" => "jp.co.liica.physics",
        "2" => "com.atomic.apps.medical.disease.condition.dictionary",
        "3" => "com.hottrix.ibeerfree",
        "4" => "com.sega.sonicjumpfever",
        "5" => "com.livewallpaperkkpicture.cat",
        "6" => "pl.thalion.achieve.productivity.timer",
        "7" => "com.expensemanager",
        "8" => "com.itsoftgroup.medicine",
        "9" => "com.cfinc.iconkisekae",
        "11" => "scare.your.friends.prank.maze.halloween"
      }

      app_identifier = apps[android_app_id.to_s]

      # app_identifier = AndroidApp.find(android_app_id).app_identifier
      file_name = apk_file_name(app_identifier)

      ApkDownloader.download!(app_identifier, file_name)

    rescue => e

      best_account.flags += 1
      best_account.in_use = false
      best_account.save!

      ApkSnapshotException.create(apk_snapshot_id: apk_snap.id, name: e.message, backtrace: e.backtrace, try: @try, apk_snapshot_job_id: apk_snapshot_job_id, google_account_id: best_account.id)

      if (@try += 1) < MAX_TRIES
        retry
      else
        apk_snap.status = :failure
        apk_snap.save!
      end

    else

      end_time = Time.now()
      download_time = (end_time - start_time).to_s
      unpack_time = PackageSearchService.search(app_identifier, apk_snap.id, file_name)

      apk_snap.google_account_id = best_account.id
      apk_snap.download_time = download_time
      apk_snap.unpack_time = unpack_time
      apk_snap.status = :success
      apk_snap.save!

      best_account.in_use = false
      best_account.save!

      File.delete(file_name)
      
    end

  end

  def optimal_account(android_app_id, apk_snapshot_job_id)
    n = GoogleAccount.where(in_use: false).count
    (0...n).each do |a|
      ga = GoogleAccount.select(:id).where(in_use: false).order(:last_used).limit(5).sample
      ga.last_used = DateTime.now
      ga.save!

      c = ApkSnapshot.where(google_account_id: ga.id, :updated_at => (DateTime.now - 1)..DateTime.now).count 
      if c < 1400
        best_account = GoogleAccount.find(ga.id)
        best_account.in_use = true
        best_account.save!
        p = Proxy.order(last_used: :asc).limit(5).sample
        return best_account, p.private_ip
      end
    end
    false
  end

end