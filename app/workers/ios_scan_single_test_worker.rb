class IosScanSingleTestWorker < IosScanSingleServiceWorker

  sidekiq_options backtrace: true, queue: :ios_live_scan_test

  # unique parameters to a test live scan
  def execute_scan_type(ipa_snapshot_id:, bid:)
    run_scan(ipa_snapshot_id: ipa_snapshot_id, purpose: :test, bid: bid, start_classify: Rails.env.production?)
  end
end