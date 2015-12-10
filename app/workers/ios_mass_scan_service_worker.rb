class IosMassScanServiceWorker

  include Sidekiq::Worker

  # retrying the json lookup ourselves, so disable
  sidekiq_options backtrace: true, retry: false, queue: :ios_live_scan_cloud #queue should be ios_mass_scan_cloud for this

  include IosCloud

  def no_data(ipa_snapshot_job_id, ios_app_id)
    IosApp.find(ios_app_id).update(display_type: :taken_down) # not entirely correct...could be foreign
    "Not available"
  end

  def paid_app(ipa_snapshot_job_id, ios_app_id)
    IosApp.find(ios_app_id).update(display_type: :paid)
    "Cannot scan paid app"
  end

  def allow_update_check?(ipa_snapshot_job_id, ios_app_id)
    Rails.env.production?
  end

  def no_update_required(ipa_snapshot_job_id, ios_app_id)
    "App has not updated"
  end

  def not_device_compatible(ipa_snapshot_job_id, ios_app_id)
    IosApp.find(ios_app_id).update(display_type: :device_incompatible)
    "No compatible devices available"
  end

  def start_job(ipa_snapshot_job_id, ios_app_id, ipa_snapshot_id)

    if Rails.env.production?
      IosScanMassServiceWorker.perform_async(ipa_snapshot_id)
    else
      IosScanMassServiceWorker.new.perform(ipa_snapshot_id)
    end
  end

  def handle_error(error:, ipa_snapshot_job_id:, ios_app_id:)
    nil
  end

end