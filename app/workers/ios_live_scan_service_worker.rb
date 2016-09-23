class IosLiveScanServiceWorker

  include Sidekiq::Worker

  # retrying the json lookup ourselves, so disable
  sidekiq_options backtrace: true, retry: false, queue: :ios_live_scan_cloud

  include IosCloud

  def no_data(ipa_snapshot_job_id, ios_app_id, international: false)
    @ipa_snapshot_job.update!(live_scan_status: :not_available)
    @ios_app.update!(
      display_type: :taken_down,
      app_store_available: false
    ) if international
    puts "Not available"
  end

  def allow_international?
    ServiceStatus.is_active?(:ios_international_live_scan) &&
      @ipa_snapshot_job.international_enabled?
  end

  def not_ios(ipa_snapshot_job_id, ios_app_id)
    @ipa_snapshot_job.update!(live_scan_status: :not_available)
    @ios_app.update!(
      display_type: :not_ios,
      app_store_available: false
    )
    puts "Not iOS"
  end

  def paid_app(ipa_snapshot_job_id, ios_app_id)
    @ipa_snapshot_job.update!(live_scan_status: :paid)
    @ios_app.update!(display_type: :paid)
    puts "Cannot scan paid app"
  end

  def allow_update_check?(ipa_snapshot_job_id, ios_app_id)
    Rails.env.production?
  end

  def no_update_required(ipa_snapshot_job_id, ios_app_id)
    @ipa_snapshot_job.update!(live_scan_status: :unchanged)
    puts "App has not updated"
  end

  def not_device_compatible(ipa_snapshot_job_id, ios_app_id)
    @ipa_snapshot_job.update!(live_scan_status: :device_incompatible)
    @ios_app.update!(display_type: :device_incompatible)
    puts "No compatible devices available"
  end

  def start_job(ipa_snapshot_job_id, ios_app_id, ipa_snapshot_id)

    if Rails.env.production?
      if @ipa_snapshot_job.job_type == 'one_off'
        IosScanSingleServiceWorker.perform_async(ipa_snapshot_id, bid)
      elsif @ipa_snapshot_job.job_type == 'test'
        IosScanSingleTestWorker.perform_async(ipa_snapshot_id, bid)
      end
    else
      if @ipa_snapshot_job.job_type == 'one_off'
        IosScanSingleServiceWorker.new.perform(ipa_snapshot_id, bid)
      elsif @ipa_snapshot_job.job_type == 'test'
        IosScanSingleTestWorker.new.perform(ipa_snapshot_id, bid)
      end
    end

    @ipa_snapshot_job.update!(live_scan_status: :initiated)
  end

  def handle_error(error:, ipa_snapshot_job_id:, ios_app_id:)
    job = IpaSnapshotJob.where(id: ipa_snapshot_job_id).first
    job.update!(live_scan_status: :failed) if job
  end

  class << self

    def test_japan_only
      # international service
      ServiceStatus.find_or_create_by!(service: 3, active: true)
      job = IpaSnapshotJob.create!(job_type: :one_off, live_scan_status: :validating, notes: 'testing international live scan', international_enabled: true)

      ios_app = IosApp.find_or_create_by(app_identifier: 987942897) # japan only app

      store = AppStore.find_or_create_by!(
        name: 'Japan',
        country_code: 'jp',
        enabled: true
      )

      AppStoresIosApp.find_or_create_by!(
        ios_app_id: ios_app.id,
        app_store_id: store.id
      )

      new.perform(job.id, ios_app.id)

    end
  end

end
