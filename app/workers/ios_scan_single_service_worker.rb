class IosScanSingleServiceWorker

	include Sidekiq::Worker

	sidekiq_options backtrace: true, queue: :ios_live_scan

	include IosWorker

  MAX_RETRIES = 1

  def initialize
    @retry = 0
  end

	def perform(ipa_snapshot_job_id, ios_app_id, bid = nil)
		execute_scan_type(ipa_snapshot_job_id: ipa_snapshot_job_id, ios_app_id: ios_app_id, bid: bid)
	end

  # unique parameters to ios live scan
  def execute_scan_type(ipa_snapshot_job_id:, ios_app_id:, bid:)
    run_scan(ipa_snapshot_job_id: ipa_snapshot_job_id, ios_app_id: ios_app_id, purpose: :one_off, bid: bid, start_classify: Rails.env.production?)
  end

  # on complete method for the run scan job. result parameter is either the resulting classdump row or an error object thrown from some exception in the method
  def on_complete(ipa_snapshot_job_id, ios_app_id, bid, result)

    snapshot = IpaSnapshot.where(ipa_snapshot_job_id: ipa_snapshot_job_id, ios_app_id: ios_app_id).first

    if result.class == ClassDump && result.success
      snapshot.download_status = :complete
      snapshot.success = true
      snapshot.save
      sdks = IosClassificationServiceWorker.new.perform(snapshot.id) if Rails.env.development? && false
      return sdks
    end

    IpaSnapshotException.create!({
      ipa_snapshot_id: snapshot.id,
      ipa_snapshot_job_id: ipa_snapshot_job_id,
      error_code: result.class == ClassDump ? result.error_code : nil,
      error: result.class == ClassDump ? result.error : result.message,
      backtrace: result.class == ClassDump ? result.trace : result.backtrace
    })

    if @retry < MAX_RETRIES && !(result.class == ClassDump && result.dump_success)
      @retry += 1
      snapshot.download_status = :retrying
      snapshot.save
      execute_scan_type(ipa_snapshot_job_id: ipa_snapshot_job_id, ios_app_id: ios_app_id,bid: bid)
    else
      snapshot.download_status = :complete
      snapshot.success = false
      snapshot.save
    end
  end

end