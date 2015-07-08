class ApkSnapshotServiceWorker
  include Sidekiq::Worker

  # sidekiq_options retry: false
  sidekiq_options :retry => 5
  
  # MAX_TRIES = 0

  # ActiveRecord::Base.logger.level = 1 if Rails.env.development?
  
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

    # @try = 0

    begin

      best_account = optimal_account(apk_snapshot_job_id, apk_snap.id)

      # 1 == accounts are blank
      # 2 == accounts are false

      raise '1' if best_account.blank?
      raise '2' if !best_account

      apk_snap.google_account_id = best_account.id
      apk_snap.save

      start_time = Time.now

      ApkDownloader.configure do |config|
        config.email = best_account.email
        config.password = best_account.password
        config.android_id = best_account.android_identifier
      end

      app_identifier = AndroidApp.find(android_app_id).app_identifier
      file_name = apk_file_name(app_identifier)

      # timeout(30) do
      #   ApkDownloader.download!(app_identifier, file_name)
      # end

      ApkDownloader.download!(app_identifier, file_name)

    rescue => e

      if e.message == '1' || e.message == '2'

        ApkSnapshotException.create(apk_snapshot_id: apk_snap.id, name: '1 or 2', backtrace: e.backtrace, apk_snapshot_job_id: apk_snapshot_job_id)

      else

        ApkSnapshotException.create(apk_snapshot_id: apk_snap.id, name: e.message, backtrace: e.backtrace, apk_snapshot_job_id: apk_snapshot_job_id, google_account_id: best_account.id)

        best_account.in_use = false
        best_account.save
     
      end

      # if (@try += 1) < MAX_TRIES
      #   retry
      # else
      #   apk_snap.status = :failure
      #   apk_snap.save
      # end

      apk_snap.status = :failure
      apk_snap.save

      raise

    else

      best_account.in_use = false
      best_account.save

      # begin
      #   unpack_time = PackageSearchService.search(app_identifier, apk_snap.id, file_name)
      # rescue => e
      #   ApkSnapshotException.create(apk_snapshot_id: apk_snap.id, name: "package error: #{e.message}", backtrace: e.backtrace, apk_snapshot_job_id: apk_snapshot_job_id)
      # else
      #   apk_snap.unpack_time = unpack_time
      # end

      unpack_time = PackageSearchService.search(app_identifier, apk_snap.id, file_name)
      
      apk_snap.unpack_time = unpack_time

      end_time = Time.now()
      download_time = (end_time - start_time).to_s

      apk_snap.google_account_id = best_account.id
      apk_snap.download_time = download_time
      apk_snap.status = :success
      apk_snap.save

      File.delete(file_name)
      
    end

  end

  def optimal_account(apk_snapshot_job_id, apk_snap_id)

    gac = GoogleAccount.count

    gac.times do |c|

      account = fresh_account

      if account.blank? && Sidekiq::Queue.new.size > 0
        200.times do |i|
          account = fresh_account
          if account.present?
            ApkSnapshotException.create(apk_snapshot_id: apk_snap_id, name: "accounts froze for #{i} seconds", apk_snapshot_job_id: apk_snapshot_job_id)
            break
          end
          sleep 1
        end
      end

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
      ga = GoogleAccount.lock.where(in_use: false).order(:last_used).limit(3).sample
      ga.last_used = DateTime.now
      ga.save
      ga
    end
  end


end