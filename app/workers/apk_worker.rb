module ApkWorker

  def perform(apk_snapshot_job_id, bid, app_id)
    download_apk(apk_snapshot_job_id, bid, app_id)
  end
  
  def apk_file_path
    if Rails.env.production?
      file_path = "/mnt/apk_files/"
    elsif Rails.env.development?
      file_path = "../apk_files/"
    end
    file_path
  end

  def download_apk(apk_snapshot_job_id, bid, android_app_id)

    begin

      raise "no android_app_id" if android_app_id.blank?

      apk_snap = ApkSnapshot.where(android_app_id: android_app_id, apk_snapshot_job_id: apk_snapshot_job_id).first

      if apk_snap.nil?

        apk_snap = ApkSnapshot.create(android_app_id: android_app_id, apk_snapshot_job_id: apk_snapshot_job_id, try: 1)

        @try_count = 1

      else

        raise "quit" if apk_snap.try > 1 && apk_snap.status.present? && %w(bad_device out_of_country taken_down).any?{|x| apk_snap.status.include? x } if single_queue?
        
        apk_snap.try += 1
        apk_snap.save

        # raise "data flag" if apk_snap.android_app.data_flag

        @try_count = apk_snap.try

      end

      raise "no snap id" if apk_snap.id.blank?

      # raise "not in america" unless apk_snap.android_app.in_america?

      best_account = optimal_account(apk_snap_id: apk_snap.id)

      raise "no best account" if best_account.blank?

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

      file_name = apk_file_path + app_identifier + ".apk"

      ApkDownloader.download!(app_identifier, file_name, apk_snap.id)

    rescue => e

      # li "\n"
      # li e.backtrace
      # li "\n"

      status_code = e.message.to_s.split("| status_code:")[1].to_s.strip

      message = e.message.to_s.split("| status_code:")[0].to_s.strip

      apk_snap_id = apk_snap.blank? ? nil : apk_snap.id

      best_account_id = best_account.present? ? best_account.id : nil

      ApkSnapshotException.create(apk_snapshot_id: apk_snap_id, name: message, backtrace: e.backtrace, try: @try_count, apk_snapshot_job_id: apk_snapshot_job_id, google_account_id: best_account_id, status_code: status_code)
      
      if best_account.present?
        best_account.in_use = false
        best_account.save
      end

      if message.include? "Couldn't connect to server"
        
        apk_snap.status = :could_not_connect

      elsif message.include?("execution expired") || message.include?("Timeout was reached")
        
        apk_snap.status = :timeout

      elsif message.include? "Mysql2::Error: Deadlock found when trying to get lock"
        
        apk_snap.status = :deadlock

      end

      apk_snap.auth_token = ''

      apk_snap.last_device = best_account.device.to_sym unless best_account.blank?

      apk_snap.save
      
      #need_to_raise = retry_possibly(apk_snapshot_job_id, bid, android_app_id)

      #raise if need_to_raise

      raise 
    else

      end_time = Time.now()
      download_time = (end_time - start_time).to_s

      best_account.in_use = false
      best_account.flags = 0
      best_account.save

      # rename file with version

      version = PackageVersion.get(file_name: file_name)

      # file_name_with_version = apk_file_path + app_identifier + '_' + version + '.apk'
      # File.rename(file_name, file_name_with_version)
      apk_snap.version = version if version.present?
      
      # update snapshot with new data

      apk_snap.google_account_id = best_account.id
      # apk_snap.last_device = GoogleAccount.devices[best_account.device]
      apk_snap.last_device = best_account.device.to_sym
      apk_snap.download_time = download_time
      apk_snap.status = :success
      # apk_snap.auth_token = nil
      
      # af = ApkFile.create!(apk: open(file_name))  # jlew -- don't upload entire thing anymore

      # jlew -- save dex
      af = ApkFile.new
      af.json_dump = json_dump(file_name)
      af.json_dump_file_name = "#{aa.app_identifier}.json"
      af.save!

      apk_snap.apk_file = af

      # debugging
      apk_snap.auth_token = ''

      apk_snap.last_updated = DateTime.now

      apk_snap.save

      # save snapshot to app

      aa.newest_apk_snapshot_id = apk_snap.id
      aa.save

      File.delete(file_name)

      PackageSearchServiceSingleWorker.perform_async(android_app_id) if single_queue?
      
    end

  end


  def optimal_account(apk_snap_id:, interval: 0.5, wait: 60, max_flags: 10)
      (wait/interval).to_i.times do
        ga = GoogleAccount.where(scrape_type: single_queue? ? 1:0, device: new_device(apk_snap_id, max_flags), blocked: false).where('flags <= ? AND last_used <= ?', max_flags, 5.seconds.ago).sample
        if ga.present?
          ga.last_used = DateTime.now
          ga.save
          return ga
        end
        sleep interval
      end
  end

  def new_device(apk_snap_id, max_flags)
    ga = ApkSnapshot.find_by_id(apk_snap_id).google_account
    last_device = ga.nil? ? -1 : GoogleAccount.devices[ga.device]
    d = GoogleAccount.where('flags <= ? AND device != ?', max_flags, last_device).where(blocked: false).sample.device
    d_name = d.blank? ? GoogleAccount.where('flags <= ?', max_flags).where(blocked: false).sample.device : d
    GoogleAccount.devices[d_name]
  end

  def json_dump(apk_file_path)
    unzipped_apk = Zip::File.open(apk_file_path)

    {'dex_classes' => dex_classes(apk_file_path), 'js_tags' => js_tags(unzipped_apk), 'dlls' => dlls(unzipped_apk)}.to_json
  end

  # Get all of the classes from the DEX
  # @author Jason Lew
  # @param apk_file_path The path to the zipped APK
  def dex_classes(apk_file_path)
    apk = Android::Apk.new(apk_file_path)
    dex = apk.dex
    dex_classes = dex.classes.map(&:name)
  end

  # Get all of the JS tags
  # @author Jason Lew
  # @param unzipped_apk The unzipped APK
  def js_tags(unzipped_apk)
    files = unzipped_apk.glob('assets/www/*')
    files.map do |file|
      contents = file.get_input_stream.read
      contents.scan(/<script src=.*\/(.*.js)/)
    end.flatten.compact.uniq
  end

  # Get all of the DLLs
  # @author Jason Lew
  # @param unzipped_apk The unzipped APK
  def dlls(unzipped_apk)
    files = [unzipped_apk.glob('META-INF/*.SF').first, unzipped_apk.glob('META-INF/*.MF').first].compact
    files.map do |file|
      contents = file.get_input_stream.read
      contents.scan(/Name: .*\/(.*.dll)/).flatten
    end.flatten.compact.uniq
  end

end