class IosScanMassServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :ios_mass_scan

  include IosWorker

  MAX_RETRIES = 1

  def initialize
    @retry = 0
  end

  # unique parameters to mass live scan
  def execute_scan_type(ipa_snapshot_id:, bid:)
    run_scan(ipa_snapshot_id: ipa_snapshot_id, purpose: :mass, bid: bid, start_classify: false)
  end

  # on complete method for the run scan job. result parameter is either the resulting classdump row or an error object thrown from some exception in the method
  def on_complete(ipa_snapshot_id:, bid:, result:)

    snapshot = IpaSnapshot.find(ipa_snapshot_id)

    if result.class == ClassDump && result.success
      snapshot.download_status = :complete
      snapshot.success = true
      snapshot.save
      return snapshot
    end

    IpaSnapshotException.create!({
      ipa_snapshot_id: snapshot.id,
      ipa_snapshot_job_id: snapshot.ipa_snapshot_job_id,
      error_code: result.class == ClassDump ? result.error_code : nil,
      error: result.class == ClassDump ? result.error : result.message,
      backtrace: result.class == ClassDump ? result.trace : result.backtrace
    })

    if @retry < MAX_RETRIES && !(result.class == ClassDump && result.dump_success)
      @retry += 1
      snapshot.download_status = :retrying
      snapshot.save
      execute_scan_type(ipa_snapshot_id: ipa_snapshot_id, bid: bid)
    else
      snapshot.download_status = :complete
      snapshot.success = false
      snapshot.save
    end
  end

end