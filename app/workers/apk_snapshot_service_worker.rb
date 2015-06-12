require 'timeout'

class ApkSnapshotServiceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false
  
  MAX_TRIES = 10

  ActiveRecord::Base.logger.level = 1 if Rails.env.development?
  
  def perform(apk_snapshot_job_id, app_id)
    asj = ApkSnapshotJob.select(:is_fucked).where(id: apk_snapshot_job_id)[0]
    download_apk(apk_snapshot_job_id, app_id) unless asj.is_fucked
  end
  
  def apk_file_name(app_identifier)
    if Rails.env.production?
      file_name = "/mnt/apk_files" + app_identifier + ".apk"
    elsif Rails.env.development?
      file_name = "../apk_files/" + app_identifier + ".apk"
    end
    
    file_name
  end

  def download_apk(apk_snapshot_job_id, android_app_id)

    v = AndroidAppSnapshot.select(:version).where(android_app_id: android_app_id).first
    apk_snap = ApkSnapshot.create(version: v.version, android_app_id: android_app_id, apk_snapshot_job_id: apk_snapshot_job_id)

    @try = 0

    begin

      google_account_id, email, password, android_id, proxy = optimal_account(android_app_id, apk_snapshot_job_id)

      if !google_account_id
        j = ApkSnapshotJob.find(apk_snapshot_job_id)
        j.is_fucked = true
        j.save!
        li "All of your accounts are fucked."
        @try = MAX_TRIES
        return false
      else

        status = Timeout::timeout(300) {

          apk_snap.google_account_id = google_account_id
          apk_snap.save!

          start_time = Time.now()
          ApkDownloader.configure do |config|
            config.email = email
            config.password = password
            config.android_id = android_id
            config.proxy = proxy
          end
          app_identifier = AndroidApp.select(:app_identifier).where(id: android_app_id)[0]["app_identifier"]
          file_name = apk_file_name(app_identifier)
          print "\nDownloading #{app_identifier}... "

          ApkDownloader.download! app_identifier, file_name

        }

      end

    rescue Exception => e

      if e.message.include? "Unable to authenticate with Google"
        block_account(google_account_id, e.message)
      elsif e.message.include? "Bad status"
        flag_account(google_account_id, e.message)
      elsif e.message.include?("abort then interrupt!") && Rails.env.development?
        j = ApkSnapshotJob.find(apk_snapshot_job_id)
        j.is_fucked = true
        j.save!
        @try = MAX_TRIES
        return false
      else
        flag_account(google_account_id, e.message)
      end

      ga = GoogleAccount.find(google_account_id)
      ga.in_use = false
      ga.save!

      ApkSnapshotException.create(apk_snapshot_id: apk_snap.id, name: e.message, backtrace: e.backtrace, try: @try, apk_snapshot_job_id: apk_snapshot_job_id, google_account_id: google_account_id)

      if (@try += 1) < MAX_TRIES
        retry
      else
        apk_snap.status = :failure
        apk_snap.save!
      end

    else

      print "success"
      end_time = Time.now()
      download_time = (end_time - start_time).to_s
      li " ( time : #{download_time} sec, account_used : #{email}) "
      unpack_time = PackageSearchService.search(app_identifier, apk_snap.id, file_name)

      apk_snap.google_account_id = google_account_id
      apk_snap.download_time = download_time
      apk_snap.unpack_time = unpack_time
      apk_snap.status = :success
      apk_snap.save!

      ga = GoogleAccount.find(google_account_id)
      ga.in_use = false
      ga.save!

      File.delete(file_name)
      
    end

  end

  def optimal_account(android_app_id, apk_snapshot_job_id)
    n = GoogleAccount.where(blocked: false, in_use: false).where("flags < ?",101).count
    (0...n).each do |a|
      ga = GoogleAccount.select(:id).where(blocked: false, in_use: false).where("flags < ?",101).order(last_used: :asc).limit(5).sample
      ga.last_used = DateTime.now
      ga.save!

      if ApkSnapshot.where(google_account_id: ga.id).where("updated_at > ?", DateTime.now - 1).count < 1400
        best_account = GoogleAccount.find(ga.id)
        best_account.in_use = true
        best_account.save!
        p = Proxy.order(last_used: :asc).limit(5).sample
        return best_account.id, best_account.email, best_account.password, best_account.android_identifier, p.private_ip
      end

    end
    false
  end

  def block_account(google_account_id, message)
    li "#{message}. Trying a different account. \n"
    li "Account with `id` #{google_account_id} is being blocked"
    ga = GoogleAccount.where(id: google_account_id)[0]
    ga.blocked = true
    ga.save!
  end

  def flag_account(google_account_id, message)
    li "#{message}. Trying again. \n"
    li "Account with `id` #{google_account_id} is being flagged"
    ga = GoogleAccount.where(id: google_account_id)[0]
    ga.flags += 1
    ga.save!
  end
  
end