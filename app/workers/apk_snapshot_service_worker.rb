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

      best_account = optimal_account()

      apk_snap.google_account_id = best_account.id
      apk_snap.save

      email = best_account.email
      password = best_account.password
      android_identifier = best_account.android_identifier

      start_time = Time.now()

      timeout(120)
        ApkDownloader.configure do |config|
          config.email = email
          config.password = password
          config.android_id = android_identifier
        end
      end

      app_identifier = AndroidApp.find(android_app_id).app_identifier
      file_name = apk_file_name(app_identifier)

      timeout(300) do
        ApkDownloader.download!(app_identifier, file_name)
      end

    rescue => e

      best_account.in_use = false
      best_account.save

      ApkSnapshotException.create(apk_snapshot_id: apk_snap.id, name: e.message, backtrace: e.backtrace, try: @try, apk_snapshot_job_id: apk_snapshot_job_id, google_account_id: best_account.id)

      if (@try += 1) < MAX_TRIES
        retry
      else
        apk_snap.status = :failure
        apk_snap.save
      end

    else

      end_time = Time.now()
      download_time = (end_time - start_time).to_s
      unpack_time = PackageSearchService.search(app_identifier, apk_snap.id, file_name)

      apk_snap.google_account_id = best_account.id
      apk_snap.download_time = download_time
      apk_snap.unpack_time = unpack_time
      apk_snap.status = :success
      apk_snap.save

      best_account.in_use = false
      best_account.save

      File.delete(file_name)
      
    end

  end

  def optimal_account

    ga = GoogleAccount.where(in_use: false).order(:last_used)

    ga.each do |a|

      best = ga.limit(5).sample
      best.last_used = DateTime.now
      best.save

      c = ApkSnapshot.where(google_account_id: best.id, :updated_at => (DateTime.now - 1)..DateTime.now).count 

      if c < 1400
        best.in_use = true
        best.save
        return best
      end

    end

    false

  end

end