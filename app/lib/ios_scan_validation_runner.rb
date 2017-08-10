class IosScanValidationRunner

  attr_accessor :options, :ipa_snapshot_job_id, :ios_app_id, :app_info, :app_store_id
  attr_writer :redis

  class NoRegisteredStores; end

  class NoStores < RuntimeError; end
  class NoData < RuntimeError; end
  class NotIos < RuntimeError; end
  class NotDeviceCompatible < RuntimeError; end
  class NotFree < RuntimeError; end

  def initialize(ipa_snapshot_job_id, ios_app_id, options={})
    @ipa_snapshot_job_id = ipa_snapshot_job_id
    @ios_app_id = ios_app_id
    @options = options
    @app_info = nil
    @app_store_id = nil
    @redis = nil
  end

  def redis
    return @redis if @redis
    @redis = Redis.new(host: ENV['VARYS_REDIS_URL'], port: ENV['VARYS_REDIS_PORT'])
  end

  def recent_key
    "varys-ios-scan-#{@ios_app_id}"
  end

  def run
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
    start_job unless @options[:disable_job_start]
  rescue
    update_job(status: :failed) if @options[:update_job_status]
    raise
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
    worker.perform_async(ipa_snapshot.id, bid)
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
    last_snap = IosApp.find(@ios_app_id).newest_ipa_snapshot
    return true if version.blank? or last_snap.nil? or last_snap.version.nil? or last_snap.version.chomp != version.chomp

    last_snap.update!(good_as_of_date: Time.now)
    false
  end

  def validate_ios!
    # mac apps are 'mac-software'
    if not (@app_info['wrapperType'] == 'software' && @app_info['kind'] == 'software')
      log_result(reason: :not_ios) if @options[:log_result]
      update_job(status: :not_available) if @options[:update_job_status]
      IosApp.find(@ios_app_id).update!(display_type: :not_ios)
      raise NotIos
    end
  end

  def validate_price!
    if @app_info['price'].to_f > 0
      log_result(reason: :paid) if @options[:log_result]
      update_job(status: :paid) if @options[:update_job_status]
      IosApp.find(@ios_app_id).update!(display_type: :paid)
      raise NotFree
    end
  end

  def validate_device_compatible!
    devices = @app_info['supportedDevices']
    available_devices = IosDeviceFamily.where(active: true).pluck(:lookup_name).compact
    if not (devices & available_devices).any?
      log_result(reason: :device_incompatible) if @options[:log_result]
      update_job(status: :device_incompatible) if @options[:update_job_status]
      IosApp.find(@ios_app_id).update!(display_type: :device_incompatible)
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
    app_identifier = IosApp.find(@ios_app_id).app_identifier
    stores = AppStore.joins(:ios_apps)
      .where('ios_apps.id = ?', @ios_app_id)
      .where(enabled: true, tos_valid: true).where.not(priority: nil)
      .order(:priority)

    if not @options[:enable_international]
      stores = stores.select { |store| store.country_code == 'US' } # us only
    end

    return NoRegisteredStores unless stores.present?

    res = nil
    available_store = stores.find do |store|
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
      ios_app_identifier: IosApp.find(@ios_app_id).app_identifier.to_s,
      cause: reason,
      created_at: DateTime.now
    }]).send!
  rescue => e
    Bugsnag.notify(e)
  end

  def update_job(status:)
    job = IpaSnapshotJob.find(@ipa_snapshot_job_id).update!(live_scan_status: status)
  end
end
