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

      # best_account = optimal_account(apk_snapshot_job_id)
      best_account = mutex_account(apk_snapshot_job_id)

      if !best_account
        ApkSnapshotException.create(apk_snapshot_id: apk_snap.id, name: "all accounts are being used or dead", try: @try, apk_snapshot_job_id: apk_snapshot_job_id, google_account_id: best_account.id)
      end

      apk_snap.google_account_id = best_account.id
      apk_snap.save

      start_time = Time.now()

      ApkDownloader.configure do |config|
        config.email = best_account.email
        config.password = best_account.password
        config.android_id = best_account.android_identifier
      end

      app_identifier = AndroidApp.find(android_app_id).app_identifier
      file_name = apk_file_name(app_identifier)

      timeout(180) do
        ApkDownloader.download!(app_identifier, file_name)
      end

    rescue => e

      ApkSnapshotException.create(apk_snapshot_id: apk_snap.id, name: e.message, backtrace: e.backtrace, try: @try, apk_snapshot_job_id: apk_snapshot_job_id, google_account_id: best_account.id)

      best_account.in_use = false
      best_account.save

      if (@try += 1) < MAX_TRIES
        retry
      else
        apk_snap.status = :failure
        apk_snap.save
      end

    else

      best_account.in_use = false
      best_account.save

      end_time = Time.now()
      download_time = (end_time - start_time).to_s
      unpack_time = PackageSearchService.search(app_identifier, apk_snap.id, file_name)

      apk_snap.google_account_id = best_account.id
      apk_snap.download_time = download_time
      apk_snap.unpack_time = unpack_time
      apk_snap.status = :success
      apk_snap.save

      File.delete(file_name)
      
    end

  end

  def mutex_account(apk_snapshot_job_id)
    mutex = RedisMutex.new(:optimal_account)
    if mutex.lock
      optimal_account()
      mutex.unlock
    else
      ApkSnapshotException.create(name: "failed to acquire lock!", apk_snapshot_job_id: apk_snapshot_job_id)
    end
  end

  def optimal_account
    ga = GoogleAccount.where(in_use: false).order(:last_used).limit(5)
    return false if ga.nil?
    ga.each do |a|
      a.last_used = DateTime.now
      a.save
      next if ApkSnapshot.where(google_account_id: a.id, :updated_at => (DateTime.now - 1)..DateTime.now).count > 1400
      a.in_use = true
      a.save
      return a
    end
    return false
  end

end