class IosLiveScanServiceWorker

  include Sidekiq::Worker

  # retrying the json lookup ourselves, so disable
  sidekiq_options backtrace: true, retry: false, queue: :ios_live_scan_cloud

  include IosCloud

  def no_data(ipa_snapshot_job_id, ios_app_id)
    IpaSnapshotJob.find(ipa_snapshot_job_id).update(live_scan_status: :not_available)
    IosApp.find(ios_app_id).update(display_type: :taken_down) # not entirely correct...could be foreign
    "Not available"
  end

  def paid_app(ipa_snapshot_job_id, ios_app_id)
    IpaSnapshotJob.find(ipa_snapshot_job_id).update(live_scan_status: :paid)
    IosApp.find(ios_app_id).update(display_type: :paid)
    "Cannot scan paid app"
  end

  def allow_update_check?(ipa_snapshot_job_id, ios_app_id)
    Rails.env.production?
  end

  def no_update_required(ipa_snapshot_job_id, ios_app_id)
    IpaSnapshotJob.find(ipa_snapshot_job_id).update(live_scan_status: :unchanged)
    "App has not updated"
  end

  def not_device_compatible(ipa_snapshot_job_id, ios_app_id)
    IpaSnapshotJob.find(ipa_snapshot_job_id).update(live_scan_status: :device_incompatible)
    IosApp.find(ios_app_id).update(display_type: :device_incompatible)
    "No compatible devices available"
  end

  def start_job(ipa_snapshot_job_id, ios_app_id, ipa_snapshot_id)

    job = IpaSnapshotJob.find(ipa_snapshot_job_id)
    if Rails.env.production?

      batch = Sidekiq::Batch.new
      batch.description = "running a live scan job"
      bid = batch.bid

      batch.jobs do
        if job.job_type == 'one_off'
          IosScanSingleServiceWorker.perform_async(ipa_snapshot_id, bid)
        elsif job.job_type == 'test'
          IosScanSingleTestWorker.perform_async(ipa_snapshot_id, bid)
        end
      end
    else
      if job.job_type == 'one_off'
        IosScanSingleServiceWorker.new.perform(ipa_snapshot_id, nil)
      elsif job.job_type == 'test'
        IosScanSingleTestWorker.new.perform(ipa_snapshot_id, nil)
      end
    end

    job.live_scan_status = :initiated
    job.save
  end

  def handle_error(error:, ipa_snapshot_job_id:, ios_app_id:)
    job = IpaSnapshotJob.where(id: ipa_snapshot_job_id).first
    job.update(live_scan_status: :failed) if !job.nil?
  end

end