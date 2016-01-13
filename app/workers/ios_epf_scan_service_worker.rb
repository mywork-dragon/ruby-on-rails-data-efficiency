class IosEpfScanServiceWorker < IosMassScanServiceWorker
  def start_job(ipa_snapshot_job_id, ios_app_id, ipa_snapshot_id)
    if Rails.env.production?
      unless batch.nil?
        batch.jobs do
          IosScanEpfServiceWorker.perform_async(ipa_snapshot_id)
        end
      else
        IosScanEpfServiceWorker.perform_async(ipa_snapshot_id)
      end
    else
      IosScanEpfServiceWorker.new.perform(ipa_snapshot_id)
    end
  end

  # TODO: maybe enable
  # def handle_error(error:, ipa_snapshot_job_id:, ios_app_id:)
  #   raise error
  # end
end