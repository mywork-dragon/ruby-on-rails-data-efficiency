class ApkSnapshotServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => false, queue: :sdk
  
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

    begin

      raise "no android_app_id" if android_app_id.blank?

      apk_snap = ApkSnapshot.where(android_app_id: android_app_id, apk_snapshot_job_id: apk_snapshot_job_id).first

      if apk_snap.nil?

        apk_snap = ApkSnapshot.create(android_app_id: android_app_id, apk_snapshot_job_id: apk_snapshot_job_id, try: 1)

        @try_count = 1

      else

        apk_snap.try += 1
        apk_snap.save

        @try_count = apk_snap.try

      end

      raise "no snap id" if apk_snap.id.blank?

      best_account = optimal_account(apk_snapshot_job_id, apk_snap.id)

      apk_snap.google_account_id = best_account.id
      apk_snap.save

      start_time = Time.now

      ApkDownloader.configure do |config|
        config.email = best_account.email
        config.password = best_account.password
        config.android_id = best_account.android_identifier
      end

      aa = AndroidApp.find_by_id(android_app_id)

      app_identifier = aa.app_identifier

      raise "no app_identifier" if app_identifier.blank?

      file_name = apk_file_name(app_identifier)

      ApkDownloader.download!(app_identifier, file_name, apk_snap.id)

    rescue => e

      status_code = e.message.to_s.split("| status_code:")[1].to_s.strip

      message = e.message.to_s.split("| status_code:")[0].to_s.strip

      ApkSnapshotException.create(apk_snapshot_id: apk_snap.id, name: message, backtrace: e.backtrace, try: @try_count, apk_snapshot_job_id: apk_snapshot_job_id, google_account_id: best_account.id, status_code: status_code)
      best_account.in_use = false
      best_account.save
      
      if message.include? "Couldn't connect to server"
        apk_snap.status = :could_not_connect
        apk_snap.save
      elsif message.include? "execution expired"
        apk_snap.status = :timeout
        apk_snap.save
      elsif message.include? "Mysql2::Error: Deadlock found when trying to get lock"
        apk_snap.status = :deadlock
        apk_snap.save
      end
      
      raise

    else

      best_account.in_use = false
      best_account.save

      unpack_time = PackageSearchService.search(app_identifier, apk_snap.id, file_name)
      
      apk_snap.unpack_time = unpack_time

      end_time = Time.now()
      download_time = (end_time - start_time).to_s

      apk_snap.google_account_id = best_account.id
      apk_snap.download_time = download_time
      apk_snap.status = :success
      apk_snap.save

      # aa.newest_apk_snapshot_id = apk_snap.id
      # aa.save

      File.delete(file_name)
      
    end

  end

  def optimal_account(apk_snapshot_job_id, apk_snap_id)

    gac = GoogleAccount.count

    gac.times do |c|

      account = fresh_account

      # if account.blank? && Sidekiq::Queue.new.size > 0
      #   200.times do |i|
      #     account = fresh_account
      #     if account.present?
      #       ApkSnapshotException.create(apk_snapshot_id: apk_snap_id, name: "accounts froze for #{i} seconds", apk_snapshot_job_id: apk_snapshot_job_id)
      #       break
      #     end
      #     sleep 1
      #   end
      # end

      if account.present?
        next if ApkSnapshot.where(google_account_id: account.id, :updated_at => (DateTime.now - 1)..DateTime.now).count > 1400
        account.in_use = true
        account.save
        return account
      elsif c < gac
        next
      else
        return false
      end

    end

    false

  end

  def fresh_account
    GoogleAccount.transaction do
      ga = GoogleAccount.lock.where(in_use: false).order(:last_used).first
      # ga = GoogleAccount.lock.where('id > ?',45).order(:last_used).first
      ga.last_used = DateTime.now
      ga.save
      ga
    end
  end

end