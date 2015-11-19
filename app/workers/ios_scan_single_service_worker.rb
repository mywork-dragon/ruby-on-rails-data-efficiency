class IosScanSingleServiceWorker

	include Sidekiq::Worker

	sidekiq_options backtrace: true, queue: :ios_live_scan

	include IosWorker

  MAX_RETRIES = 1

  def initialize
    @retry = 0
  end

	def perform(ipa_snapshot_job_id, app_identifier, bid = nil)
		run_scan(ipa_snapshot_job_id: ipa_snapshot_job_id, app_identifier: app_identifier, purpose: :one_off, bid: bid, start_classify: Rails.env.production?)
	end

  # on complete method for the run scan job. result parameter is either the resulting classdump row or an error object thrown from some exception in the method
  def on_complete(ipa_snapshot_job_id, app_identifier, bid, result)

    snapshot = IpaSnapshot.where(ipa_snapshot_job_id: ipa_snapshot_job_id, ios_app_id: app_identifier).first

    if result.class == ClassDump && result.success
      # TODO: maybe kick off new job here
      snapshot.status = :complete
      snapshot.success = true
      snapshot.save
      IosClassificationServiceWorker.new.perform(snapshot.id) if Rails.env.development?
      return
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
      snapshot.status = :retrying
      snapshot.save
      run_scan(ipa_snapshot_job_id, app_identifier, :one_off, bid)
    else
      snapshot.status = :complete
      snapshot.success = false
      snapshot.save
    end
  end

end