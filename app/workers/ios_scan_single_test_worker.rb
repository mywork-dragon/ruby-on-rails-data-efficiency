class IosScanSingleTestWorker < IosScanSingleServiceWorker

  sidekiq_options backtrace: true, queue: :ios_live_scan_test

  def perform(ipa_snapshot_job_id, ios_app_id, bid = nil)
    run_scan(ipa_snapshot_job_id: ipa_snapshot_job_id, ios_app_id: ios_app_id, purpose: :test, bid: bid, start_classify: Rails.env.production?)
  end
end