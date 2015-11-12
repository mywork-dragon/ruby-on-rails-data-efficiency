class IosScanSingleServiceWorker

	include Sidekiq::Worker

	sidekiq_options backtrace: true, queue: :ios_live_scan

	include IosWorker

  MAX_RETRIES = 1

  def initialize
    @retry = 0
  end

	def perform(ipa_snapshot_job_id, app_identifier, bid = nil)
		run_scan(ipa_snapshot_job_id, app_identifier, :one_off, bid)
	end

  # on complete method for the run scan job. result parameter is either the resulting classdump row or an error object thrown from some exception in the method
  def on_complete(ipa_snapshot_job_id, app_identifier, bid, result)

    snapshot = IpaSnapshot.where(ipa_snapshot_job_id: ipa_snapshot_job_id, ios_app_id: app_identifier).first

    if result.class == ClassDump && result.success
      snapshot[:status] = :complete
      snapshot[:success] = true
      snapshot.save
      return
    end

    IpaSnapshotExceptions.create!({
      ipa_snapshot_id: snapshot.id,
      ipa_snapshot_job_id: ipa_snapshot_job_id,
      error_code: result.error_code if result.class == ClassDump
      error: result.class == ClassDump ? result.error : result.message
      backtrace: result.class == ClassDump ? result.trace : result.backtrace
    })

    if @retry < MAX_RETRIES
      @retry += 1
      run_scan(ipa_snapshot_job_id, app_identifier, :one_off, bid)
    else
      snapshot[:status] = :complete
      snapshot[:success] = false
      snapshot.save
    end
  end

end