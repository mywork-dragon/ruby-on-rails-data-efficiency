class IosScanValidationRunner

  attr_accessor :options, :ipa_snapshot_job_id, :ios_app_id, :app_info, :app_store_id
  attr_writer :redis

  class NoRegisteredStores; end

  class NoStores < RuntimeError; end
  class NoData < RuntimeError; end
  class NotIos < RuntimeError; end
  class NotDeviceCompatible < RuntimeError; end
  class NotFree < RuntimeError; end
  class NoDevicesAvailable < RuntimeError; end

  def initialize(ipa_snapshot_job_id, ios_app_id, options={})
    @ipa_snapshot_job_id = ipa_snapshot_job_id
    @ios_app_id = ios_app_id
    @options = options
    @priority = options[:classification_priority]
    @app_info = nil
    @app_store_id = nil
    @redis = nil
  end

  def redis
    @redis ||= Redis.new(host: ENV['VARYS_REDIS_URL'], port: ENV['VARYS_REDIS_PORT'])
  end

  def recent_key
    "varys-ios-scan-#{@ios_app_id}"
  end

  def run
    p "Will try to run #{@ios_app_id}"
    @app_info = lookup_app
    validate_itunes_response!
    validate_ios!
    validate_price!
    validate_device_compatible!
    if @options[:enable_update_check] and not should_update?
      return handle_no_update
    end
    if @options[:enable_recent_queue_check] and recently_queued?
      return handle_recently_queued
    end

    if @options[:disable_job_start]
      return
    end

    # For mass scan, distribute the tasks between the scanning systems.
    # For live scan, queue on both.
    # if @options[:classification_priority] == :high
    #   start_job
    #   start_job_v2 if @options[:v2_download]
    # else
    #   if rand * 100 <= 50 and @options[:v2_download]
    #     start_job_v2
    #   else
    #     start_job
    #   end
    # end
    if ServiceStatus.is_active?(:ios_v1_download)
      start_job
    end

    if ServiceStatus.is_active?(:ios_v2_download)
      start_job_v2
    end

  rescue => e 
    puts e.message
    update_job(status: :failed) if @options[:update_job_status]
    raise
  end

  # create a job using v2 of the download system
  def start_job_v2
    ipa_snapshot = IpaSnapshot.create!(
      ipa_snapshot_job_id: @ipa_snapshot_job_id,
      ios_app_id: @ios_app_id,
      version: @app_info['version'],
      lookup_content: @app_info.to_json,
      app_store_id: @app_store_id,
      download_status: :starting
    )
    
    cd = ClassDump.create!(
      ipa_snapshot: ipa_snapshot,
      complete: false
    )
    
    expiration_time = options[:recently_queued_expiration] || 24.hours.to_i
    redis.setex(recent_key, expiration_time, @app_info['version'])
    
    a = @potential_accounts.sample
    raise NoDevicesAvailable, "app store id: #{@app_store_id}" if a.nil?
    
    email_hash =  a.email.gsub(/[^0-9a-zA-Z]/, '_')
                
    client = Aws::SQS::Client.new(region: 'us-east-1')
    # make sure message has all necessary attributes
    client.send_message(
      queue_url: get_queue_for(@priority, email_hash),
      message_body: JSON.dump({
        classification_priority: @priority,
        itunes_user: a.email,
        itunes_password: a.password,
        app_identifier: ios_app.app_identifier.to_s,
        varys_cd_id: cd.id,
      }))
    update_job(status: :initiated) if @options[:update_job_status]
  rescue => e
    Bugsnag.notify(e)
  end

  def start_job
    ipa_snapshot = IpaSnapshot.create!(
      ipa_snapshot_job_id: @ipa_snapshot_job_id,
      ios_app_id: @ios_app_id,
      version: @app_info['version'],
      lookup_content: @app_info.to_json,
      app_store_id: @app_store_id
    )
    worker = @options[:scan_worker]
    bid = @options[:sidekiq_batch_id]
    if bid
      batch = Sidekiq::Batch.new(bid)
      batch.jobs do
        worker.perform_async(ipa_snapshot.id, bid)
      end
    else
      worker.perform_async(ipa_snapshot.id, bid)
    end
    expiration_time = options[:recently_queued_expiration] || 24.hours.to_i
    redis.setex(recent_key, expiration_time, @app_info['version'])
    update_job(status: :initiated) if @options[:update_job_status]
  end

  def recently_queued?
    version = @app_info['version']
    res = redis.get(recent_key)
    res == version
  end

  def handle_recently_queued
      log_result(reason: :recently_queued) if @options[:log_result]
      update_job(status: :unchanged) if @options[:update_job_status]
  end

  def handle_no_update
      log_result(reason: :unchanged) if @options[:log_result]
      update_job(status: :unchanged) if @options[:update_job_status]
  end

  def should_update?
    version = @app_info['version']
    last_snap = ios_app.newest_ipa_snapshot
    return true if version.blank? or last_snap.nil? or last_snap.version.nil? or last_snap.version.chomp != version.chomp

    last_snap.update!(good_as_of_date: Time.now)
    false
  end

  def validate_ios!
    # mac apps are 'mac-software'
    unless (@app_info['wrapperType'] == 'software' && @app_info['kind'] == 'software')
      log_result(reason: :not_ios) if @options[:log_result]
      update_job(status: :not_available) if @options[:update_job_status]
      ios_app.update!(display_type: :not_ios)
      raise NotIos
    end
  end

  def validate_price!
    if @app_info['price'].to_f > 0
      log_result(reason: :paid) if @options[:log_result]
      update_job(status: :paid) if @options[:update_job_status]
      ios_app.update!(display_type: :paid)
      raise NotFree
    end
  end

  def validate_device_compatible!
    devices = @app_info['supportedDevices']
    available_devices = IosDeviceFamily.where(active: true).pluck(:lookup_name).compact
    if not (devices & available_devices).any?
      log_result(reason: :device_incompatible) if @options[:log_result]
      update_job(status: :device_incompatible) if @options[:update_job_status]
      ios_app.update!(display_type: :device_incompatible)
      raise NotDeviceCompatible
    end
  end

  def validate_itunes_response!
    if @app_info == NoRegisteredStores
      log_result(reason: :no_stores) if @options[:log_result]
      update_job(status: :not_available) if @options[:update_job_status]
      raise NoStores
    elsif @app_info == ItunesApi::EmptyResult
      log_result(reason: :no_data) if @options[:log_result]
      update_job(status: :not_available) if @options[:update_job_status]
      raise NoData
    end
  end

  def lookup_app
    app_identifier = ios_app.app_identifier
    start = Time.now
    stores = AppStore.joins(:ios_apps)
                      .where('ios_apps.id = ?', @ios_app_id)
                      .where(enabled: true, tos_valid: true)
                      .where.not(priority: nil)
                      .order(:priority)
      
    puts "Found in #{stores.count} stores"
    
    duration = Time.now - start
    Rails.logger.info "lookup_app took #{duration}s"
    
    unless @options[:enable_international]
      stores = stores.where(country_code: 'US') # us only
    end
    
    qry = ->(purpose) { IosDevice.where.not(:disabled => true).where(:purpose => IosDevice.purposes[purpose]).map(&:apple_account).uniq.compact  }

    potential_accounts = (@priority == :high) ? qry.call('one_off_scan_v2') : qry.call('scan_v2')
    viable_stores_ids = potential_accounts.map(&:app_store_id) & stores.map(&:id)
    @potential_accounts = potential_accounts.select{|pa| viable_stores_ids.include?(pa.app_store_id) }
    
    return NoRegisteredStores unless viable_stores_ids.present?

    res = nil
    available_store = stores.where(id: viable_stores_ids).find do |store|
      res = ItunesApi.lookup_app_info(
        app_identifier,
        country_code: store.country_code.downcase
      )

      res == ItunesApi::EmptyResult ? false : true
    end

    return ItunesApi::EmptyResult unless available_store

    @app_store_id = available_store.id
    res['results'].first
  end

  def log_result(reason:)
    version = @app_info['version'] if @app_info.class == Hash
    RedshiftLogger.new(records: [{
      name: 'ios_scan_validation_result',
      ios_app_id: @ios_app_id,
      ios_app_version: version,
      ios_app_identifier: ios_app.app_identifier.to_s,
      cause: reason,
      created_at: DateTime.now
    }]).send!
  rescue => e
    Bugsnag.notify(e)
  end

  def update_job(status:)
    job = IpaSnapshotJob.find(@ipa_snapshot_job_id).update!(live_scan_status: status)
  end
  
  private
  
  def get_queue_for(priority, email_hash)
    prio = priority == :high ? 'high' : 'low'
    "https://sqs.us-east-1.amazonaws.com/250424072945/decryption-queue-#{prio}-priority-#{email_hash}"
  end
  
  def ios_app 
    # Dont memoize.
    IosApp.find(@ios_app_id)
  end
  
  
end
