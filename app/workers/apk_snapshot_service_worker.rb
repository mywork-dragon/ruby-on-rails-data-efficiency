class ApkSnapshotServiceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false
  
  MAX_TRIES = 5

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

      best_account = optimal_account(apk_snapshot_job_id)

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

      ApkDownloader.download!(app_identifier, file_name)

    rescue => e

      # best_account.in_use = false
      # best_account.save

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

      # best_account.in_use = false
      # best_account.save

      File.delete(file_name)
      
    end

  end

  def optimal_account(apk_snapshot_job_id)

    ga = GoogleAccount.order(last_used: :asc).limit(5).select{ |a| a if ApkSnapshot.where(google_account_id: a.id, apk_snapshot_job_id: apk_snapshot_job_id, status: nil).count == 0 }.shuffle

    ga.each do |a|

      a.last_used = DateTime.now
      a.save

      c = ApkSnapshot.where(google_account_id: a.id, :updated_at => (DateTime.now - 1)..DateTime.now).count 

      if c < 1400
        a.in_use = true
        a.save
        return a
      end

    end

    false

  end

end