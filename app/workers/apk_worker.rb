module ApkWorker

  def perform(apk_snapshot_job_id, bid, app_id)
    download_apk(apk_snapshot_job_id, bid, app_id)
  end
  
  def apk_file_name(app_identifier)
    if Rails.env.production?
      file_name = "/mnt/apk_files/" + app_identifier + ".apk"
    elsif Rails.env.development?
      file_name = "../apk_files/" + app_identifier + ".apk"
    end
    file_name
  end

  def download_apk(apk_snapshot_job_id, bid, android_app_id)

    begin

      raise "no android_app_id" if android_app_id.blank?

      apk_snap = ApkSnapshot.where(android_app_id: android_app_id, apk_snapshot_job_id: apk_snapshot_job_id).first

      if apk_snap.nil?

        apk_snap = ApkSnapshot.create(android_app_id: android_app_id, apk_snapshot_job_id: apk_snapshot_job_id, try: 1)

        @try_count = 1

      else
        
        apk_snap.try += 1
        apk_snap.save

        raise "data flag" if apk_snap.android_app.data_flag

        @try_count = apk_snap.try

      end

      raise "no snap id" if apk_snap.id.blank?

      best_account = optimal_account(apk_snapshot_job_id, bid, apk_snap.id)

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
      best_account.flags = 0
      best_account.save

      # unpack_time = PackageSearchService.search(app_identifier, apk_snap.id, file_name)

      version = PackageSearchService.find_packages(app_identifier: app_identifier, apk_snapshot_id: apk_snap.id)
      
      # apk_snap.unpack_time = unpack_time

      apk_snap.version = version if version.present?

      end_time = Time.now()
      download_time = (end_time - start_time).to_s

      apk_snap.google_account_id = best_account.id
      apk_snap.last_device = GoogleAccount.devices[best_account.device]
      apk_snap.download_time = download_time
      apk_snap.status = :success
      apk_snap.save

      aa.newest_apk_snapshot_id = apk_snap.id
      aa.save

      # company_ids = SdkCompanyServiceWorker.new.find_company(android_app_id)

      # company_ids.each do |id|
         # SdkCompanyServiceWorker.new.google_company(id)
      # end

      File.delete(file_name)
      
    end

  end

  def optimal_account(apk_snapshot_job_id, bid, apk_snap_id)

    single_job = ApkSnapshotJob.find(apk_snapshot_job_id).notes.include? 'SINGLE: '

    gac = single_job ? LiveScanGoogleAccount.count : GoogleAccount.count

    gac.times do |c|

      account = fresh_account(apk_snap_id, single_job, bid)

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

  def fresh_account(apk_snap_id, single_job, bid)
    device = ApkSnapshot.find(apk_snap_id).last_device.to_s
    d = if device.blank? then "IS NOT NULL" else "!= #{device}" end

    stop = 10

    class_name = single_job ? 'LiveScanGoogleAccount' : 'GoogleAccount'

    account_obj = Object.const_get(class_name).new

    g = account_obj.transaction do
      ga = account_obj.lock.where(in_use: false).where("blocked = 0 AND flags <= #{stop} AND device #{d}").order(:last_used).first
      ga.last_used = DateTime.now
      ga.save
      ga
    end

    if g.blank?

      d_name = account_obj.devices.find{|k,v| v == d}.first.gsub('_',' ')

      err_msg = "All the accounts on your #{d_name} are down."
      Slackiq.notify(webhook_name: :sdk_scraper, title: err_msg, bid: bid)
      raise err_msg

    elsif g.flags >= stop

      Slackiq.notify(webhook_name: :sdk_scraper, title: "#{g.email} needs to be fixed!", bid: bid)

      g.blocked = true
      g.save

      fresh_account(apk_snap_id, bid)

    else
      return g
    end

  end

end