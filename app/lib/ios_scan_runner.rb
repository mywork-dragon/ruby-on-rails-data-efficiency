class IosScanRunner

  class UnexpectedCondition < RuntimeError; end
  class BusyDevices < RuntimeError; end
  class NoAppleAccounts < RuntimeError; end

  def initialize(ipa_snapshot_id, device_purpose, options={})
    @ipa_snapshot_id = ipa_snapshot_id
    @device_purpose = device_purpose
    @options = options
    @logger = JsonLogger.new(
      filename: Rails.application.config.dark_side_json_log_path,
      included_keys: { ipa_snapshot_id: @ipa_snapshot_id }
    )
  end

  def run
    load_job_info
    create_record
    reserve_device
    download
    release_device
    process_final_result
    complete
    cleanup
    @result
  rescue => e
    handle_error(e)
    raise
  ensure
    release_device
  end

  def release_device
    @reserver.release if defined?(@reserver) && !@reserver.released?
  end

  def complete
    @snapshot.update!(download_status: :complete, success: true)
    check_account_limits unless @options[:ignore_acct_limits]
  end

  def warning_level_map
    {
      '8' => 3000
    }
  end

  def check_account_limits
    # cannot assume reserver has them anymore
    device = @classdump.ios_device
    apple_account = @classdump.apple_account
    ios_major_version = device.ios_version.split(".").first
    warning_level = warning_level_map[ios_major_version]
    return if warning_level.nil?
    error_level = warning_level * 2

    downloads_count = apple_account.class_dumps.count
    alert_frequency = ['one_off', 'one_off_intl'].include?(device.purpose) ? 3 : 15

    message = if downloads_count == warning_level
                "*CAUTION*:exclamation:: AppleAccount #{apple_account.id} has crossed the #{warning_level} downloads threshold. *Check device #{device.id} for slowness*"
                elsif downloads_count >= error_level && (downloads_count - error_level) % alert_frequency == 0
                  "*WARNING* :skull_and_crossbones:: AppleAccount #{apple_account.id} has crossed the limit of #{error_level} downloads. *Please reset the phone and it's Apple Account*"
                end
    
    Slackiq.message(message, webhook_name: :automated_alerts) unless message.nil?
  end

  def handle_error(e)
    @logger.log_exc(e)
    log_scan_failure if @options[:log_scan_failure]
    @snapshot.update!(download_status: :complete, success: false)
  end

  def log_scan_failure
      app = @snapshot.ios_app
      store = @snapshot.app_store

      record = {
        name: 'ios_scan_failure',
        ios_app_id: app.id,
        ios_app_identifier: app.app_identifier,
        ios_app_store: store.country_code
      }

      if @reserver.device
        record[:ios_device_id] = @reserver.device.id
        record[:ios_version] = @reserver.device.ios_version    
      end

      # haven't figured out ENV variables on macs yet
      RedshiftLogger.new(
        table: 'analytics',
        cluster: 'ms-analytics',
        database: 'data',
        records: [record]).send!
  rescue => e
    Bugsnag.notify(e)
  end

  def cleanup
    FileUtils.rm_rf([@result[:summary_path], @result[:app_contents_path]]) unless @options[:save_results]
  end

  def download
    account_changed_lambda = -> { @reserver.account_changed } if @reserver.is_swap_required?
    @result = IosDownloadDeviceService.new(
      @reserver.device,
      apple_account: @reserver.apple_account,
      logger: @logger,
      account_changed_lambda: account_changed_lambda
    ).run(@snapshot.ios_app.app_identifier, @lookup_content, @device_purpose, @classdump.id) do |inc_result|
      process_incomplete_result(inc_result)
    end
  end

  def process_incomplete_result(incomplete_result)
    row = result_to_cd_row(incomplete_result)
    row[:complete] = false
    @classdump.update!(row)

    if row[:dump_success]
      @snapshot.update!(download_status: :cleaning, bundle_version: incomplete_result[:bundle_version])
      ClassdumpProcessingWorker.perform_async(@classdump.id) unless @options[:disable_cd_processing]
      @options[:classify_worker].perform_async(@snapshot.id) if @options[:start_classify]
    end
  end

  def process_final_result
    row = result_to_cd_row(@result)
    row.delete(:class_dump)
    row.delete(:app_content)
    row[:complete] = true
    @classdump.update!(row)
  end

  def create_record
    @snapshot.update!(download_status: :starting)
    @classdump = ClassDump.create!(ipa_snapshot_id: @snapshot.id)
    @logger.add_key(:classdump_id, @classdump.id)
    log "Creating classdump #{@classdump.id} for ios app #{@snapshot.ios_app_id}"
  end

  def reserve_device
    log("Reserving device and account #{Time.now}")
    requirements = build_reservation_requirements
    @reserver = IosScanReserver.new(@snapshot)
    @reserver.reserve(@device_purpose, requirements)
    validate_device!
    validate_apple_account!
    @logger.add_key(:ios_device_id, @reserver.device.id)
    @logger.add_key(:apple_account_id, @reserver.apple_account.id)
    @classdump.update!(
      apple_account_id: @reserver.apple_account.id,
      ios_device_id: @reserver.device.id
    )
    log("Reserved device #{@reserver.device.id}")
  end

  def validate_device!
    if @reserver.device.nil?
      @classdump.update!(complete: true, error_code: :devices_busy)
      raise BusyDevices
    end
  end

  def validate_apple_account!
    if @reserver.apple_account.blank?
      @classdump.update!(complete: true, error_code: :no_apple_accounts)
      raise NoAppleAccounts
    end
  end

  def load_job_info
    @snapshot = IpaSnapshot.find(@ipa_snapshot_id)
    raise UnexpectedCondition if @snapshot.ios_app.nil?
    raise UnexpectedCondition if @snapshot.lookup_content.empty?
    @lookup_content = JSON.parse(@snapshot.lookup_content)
    @logger.add_key(:ios_app_id, @snapshot.ios_app_id)
  end

  def log(msg)
    @logger.log(msg)
  end

  def build_reservation_requirements
    copy = JSON.parse(JSON.generate(@lookup_content))
    copy[:app_store_id] = @snapshot.app_store_id
    copy
  end

  # convert data coming from ios_device_service to classdump row information

  def result_to_cd_row(data)
    data_keys = [
      :success,
      :duration,
      :account_success,
      :install_time,
      :install_success,
      :dump_time,
      :dump_success,
      :teardown_success,
      :teardown_time,
      :error,
      :trace,
      :error_root,
      :error_teardown,
      :error_teardown_trace,
      :teardown_retry,
      :error_cod
    ]
    
    row = data.select { |key| data_keys.include? key }
    
    class_dump_file = File.open(data[:summary_path]) if Rails.env.production? && data[:summary_path]
    app_content_file = File.open(data[:app_contents_path]) if Rails.env.production? && data[:app_contents_path]
    
    row[:class_dump] = class_dump_file
    row[:app_content] = app_content_file
    
    row
  end
end
