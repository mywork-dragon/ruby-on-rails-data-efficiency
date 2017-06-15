class IosMassScanServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :ios_mass_lookup

  include IosCloud

  def no_data(ipa_snapshot_job_id, ios_app_id, international: false)
    @ios_app.update!(display_type: :taken_down) if international
    "Not available"
  end

  def allow_international?
    false
  end

  def not_ios(ipa_snapshot_job_id, ios_app_id)
    @ios_app.update!(
      display_type: :not_ios
    )
    "Not iOS"
  end

  def paid_app(ipa_snapshot_job_id, ios_app_id)
    @ios_app.update!(display_type: :paid)
    "Cannot scan paid app"
  end

  def allow_update_check?(ipa_snapshot_job_id, ios_app_id)
    Rails.env.production?
  end

  def no_update_required(ipa_snapshot_job_id, ios_app_id)
    "App has not updated"
  end

  def not_device_compatible(ipa_snapshot_job_id, ios_app_id)
    @ios_app.update!(display_type: :device_incompatible)
    "No compatible devices available"
  end

  def start_job(ipa_snapshot_job_id, ios_app_id, ipa_snapshot_id)

    if Rails.env.production?
      unless batch.nil?
        batch.jobs do
          IosScanMassServiceWorker.perform_async(ipa_snapshot_id)
        end
      else
        IosScanMassServiceWorker.perform_async(ipa_snapshot_id)
      end
    else
      IosScanMassServiceWorker.new.perform(ipa_snapshot_id)
    end
  end

  def handle_error(error:, ipa_snapshot_job_id:, ios_app_id:)
    nil
  end

end
