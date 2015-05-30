class ApkSnapshotServiceWorker
  include Sidekiq::Worker

  # accounting for retries ourself, so disable sidekiq retries
  sidekiq_options retry: false
  
  MAX_TRIES = 3

  # Disables ActiveRecord logging 
  ActiveRecord::Base.logger.level = 1
  
  # Not quite sure if is_fucked would be updated. Look into further.
  def perform(apk_snapshot_job_id, app_id, is_fucked)

    download_apk(apk_snapshot_job_id, app_id) unless is_fucked

    puts is_fucked

  end

  def download_apk(apk_snapshot_job_id, android_app_id)

    v = AndroidAppSnapshot.select(:version).where(android_app_id: android_app_id).first
    apk_snap = ApkSnapshots.create(version: v.version, android_app_id: android_app_id, apk_snapshot_job_id: apk_snapshot_job_id)

    try = 0

    begin

      google_accounts_id, email, password, android_id = optimal_account(android_app_id, apk_snapshot_job_id)

      ga = GoogleAccount.where(id: google_accounts_id)[0]
      ga.last_downloaded = android_app_id
      ga.save!

      start_time = Time.now()
      ApkDownloader.configure do |config|
        config.email = email
        config.password = password
        config.android_id = android_id
      end
      app_identifier = AndroidApp.select(:app_identifier).where(id: android_app_id)[0]["app_identifier"]
      file_name = "data/apk_files/" + app_identifier + ".apk"
      print "\nDownloading #{app_identifier}... "
      ApkDownloader.download! app_identifier, file_name
      

    rescue Exception => e

      if e.message.include? "Unable to authenticate with Google"
        block_account(google_accounts_id, e.message)
      elsif e.message.include? "Bad status (500)"
        block_account(google_accounts_id, e.message)
      end

      ApkSnapshotException.create(apk_snapshot: apk_snap.id, name: e.message, backtrace: e.backtrace, try: try, apk_snapshot_job_id: apk_snapshot_job_id, google_account_id: google_accounts_id)

      if (try += 1) < MAX_TRIES
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

    accounts = []
    ga = GoogleAccount.select(:id).where(blocked: false).where("flags < ?",4).where.not(last_downloaded: android_app_id).each
    for account in ga
      accounts << ApkSnapshots.where(google_accounts: account.id).where("updated_at > ?", DateTime.now - 1).count
    end
    if accounts.length == 0
      j = ApkSnapshotJobs.where(id: apk_snapshot_job_id)[0]
      j.is_fucked = true
      j.save!
      puts "It appears as though all of your accounts have been fucked."
    end
    best_account = GoogleAccount.where(id: ga.to_a[accounts.each_with_index.min[1].to_i].id)

    return best_account[0]["id"], best_account[0]["email"], best_account[0]["password"], best_account[0]["android_id"]

  end

  def block_account(google_accounts_id, message)
    puts "#{message}. Trying a different account. \n"
    puts "Account with `id` #{google_accounts_id} is being blocked"
    ga = GoogleAccount.where(id: google_accounts_id)[0]
    ga.blocked = true
    ga.save!
    # Needs to create account blocks table
  end

  def flag_account(google_accounts_id, message)
    puts "#{message}. Trying again. \n"
    puts "Account with `id` #{google_accounts_id} is being flagged"

    ga = GoogleAccount.where(id: google_accounts_id)[0]
    ga.flags += 1
    ga.save!
  end
  
end


# Test Tor to see:
  # If it's gonna take too much time to download a file
  # If Google is not going to like accounts using a ton of different ip addresses


# Flags *
# Blocks *
# Temp Blocks *
# Job Fucks 






