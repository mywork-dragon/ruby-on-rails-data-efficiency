class IosLiveScanServiceWorker

  include Sidekiq::Worker

  # retrying the json lookup ourselves, so disable
  sidekiq_options backtrace: true, retry: false, queue: :ios_live_lookup

  include IosCloud

  def no_data(ipa_snapshot_job_id, ios_app_id, international: false)
    @ipa_snapshot_job.update!(live_scan_status: :not_available)
    @ios_app.update!(
      display_type: :taken_down
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
      display_type: :not_ios
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
        # IosScanSingleServiceWorker.new.perform(ipa_snapshot_id, bid)
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

    def test_ios10_app
      app = IosApp.find_or_create_by!(app_identifier: 387771637)
      store = AppStore.find_or_create_by!(
        country_code: 'US',
        name: 'United States',
        enabled: 1,
        priority: 1,
        display_priority: 1,
        tos_valid: true,
        tos_url_path: '/us/terms.html'
      )
      AppStoresIosApp.find_or_create_by!(
        ios_app_id: app.id,
        app_store_id: store.id
      )

      job = IpaSnapshotJob.create!(
        job_type: 1,
        notes: 'testing',
        international_enabled: false
      )

      new.perform(job.id, app.id)
    end
  end

end
