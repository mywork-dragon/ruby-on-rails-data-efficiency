class ApkSnapshotServiceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false
  
  MAX_TRIES = 3

  ActiveRecord::Base.logger.level = 1 if Rails.env.development?
  
  def perform(apk_snapshot_job_id, app_id)
    asj = ApkSnapshotJob.select(:is_fucked).where(id: apk_snapshot_job_id)[0]
    download_apk(apk_snapshot_job_id, app_id) unless asj.is_fucked
  end

  def download_apk(apk_snapshot_job_id, android_app_id)

    v = AndroidAppSnapshot.select(:version).where(android_app_id: android_app_id).first
    apk_snap = ApkSnapshots.create(version: v.version, android_app_id: android_app_id, apk_snapshot_job_id: apk_snapshot_job_id)

    @try = 0

    begin

      google_accounts_id, email, password, android_id, proxy = optimal_account(android_app_id, apk_snapshot_job_id)

      if !google_accounts_id
        j = ApkSnapshotJob.where(id: apk_snapshot_job_id)[0]
        j.is_fucked = true
        j.save!
        #puts "All of your accounts are fucked."
        @try = MAX_TRIES
        return false
      else
        start_time = Time.now()
        ApkDownloader.configure do |config|
          config.email = email
          config.password = password
          config.android_id = android_id
          config.proxy = proxy
        end
        app_identifier = AndroidApp.select(:app_identifier).where(id: android_app_id)[0]["app_identifier"]
        file_name = "data/apk_files/" + app_identifier + ".apk"
        print "\nDownloading #{app_identifier}... "
        ApkDownloader.download! app_identifier, file_name
      end

    rescue Exception => e

      if e.message.include? "Unable to authenticate with Google"
        block_account(google_accounts_id, e.message)
      elsif e.message.include? "Bad status"
        flag_account(google_accounts_id, e.message)
      elsif e.message.include? "abort then interrupt!"
        j = ApkSnapshotJob.where(id: apk_snapshot_job_id)[0]
        j.is_fucked = true
        j.save!
        @try = MAX_TRIES
        return false
      else
        flag_account(google_accounts_id, e.message)
      end

      ApkSnapshotException.create(apk_snapshot_id: apk_snap.id, name: e.message, backtrace: e.backtrace, try: @try, apk_snapshot_job_id: apk_snapshot_job_id, google_account_id: google_accounts_id)

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
      puts " ( time : #{download_time} sec, account_used : #{email}) "
      unpack_time = PackageSearchService.search(app_identifier, apk_snap.id)

      apk_snap.google_accounts_id = google_accounts_id
      apk_snap.download_time = download_time
      apk_snap.unpack_time = unpack_time
      apk_snap.status = :success
      apk_snap.save!

      File.delete(file_name)
      
    end
  end

  def optimal_account(android_app_id, apk_snapshot_job_id)
    n = GoogleAccount.where(blocked: false).where("flags < ?",11).count
    (0...n).each do |a|
      ga = GoogleAccount.select(:id).where(blocked: false).where("flags < ?",11).order(last_used: :asc).limit(5).sample
      ga.last_used = DateTime.now
      ga.save!

      # Limitted

      # if ApkSnapshots.where(google_accounts: ga.id).where("updated_at > ?", DateTime.now - 1).count < 1400
      #   best_account = GoogleAccount.where(id: ga.id)
      #   p = Proxy.order(last_used: :asc).limit(5).sample
      #   return best_account[0]["id"], best_account[0]["email"], best_account[0]["password"], best_account[0]["android_identifier"], p.private_ip
      # end


      # Unlimitted

      best_account = GoogleAccount.where(id: ga.id)
      p = Proxy.order(last_used: :asc).limit(5).sample
      return best_account[0]["id"], best_account[0]["email"], best_account[0]["password"], best_account[0]["android_identifier"], p.private_ip

    end
    return false
  end

  def block_account(google_accounts_id, message)
    puts "#{message}. Trying a different account. \n"
    puts "Account with `id` #{google_accounts_id} is being blocked"
    ga = GoogleAccount.where(id: google_accounts_id)[0]
    ga.blocked = true
    ga.save!
  end

  def flag_account(google_accounts_id, message)
    puts "#{message}. Trying again. \n"
    puts "Account with `id` #{google_accounts_id} is being flagged"
    ga = GoogleAccount.where(id: google_accounts_id)[0]
    ga.flags += 1
    ga.save!
  end
  
end