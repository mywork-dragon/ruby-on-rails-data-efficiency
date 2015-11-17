class IosMockServiceWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true, queue: :ios_live_scan

  def perform(ipa_snapshot_job_id, app_identifier, purpose, bid = nil)

    # kick off and monitor an ios scan
    if purpose == :one_off
      if Rails.env.production?
        IosScanSingleServiceWorker.perform_async(ipa_snapshot_job_id, app_identifier, bid) 
      else
        IosScanSingleServiceWorker.new.perform(ipa_snapshot_job_id, app_identifier, bid)
      end

      start = Time.now
      result = nil

      loop do

        snapshot = IpaSnapshot.uncached { IpaSnapshot.where(ipa_snapshot_job_id: ipa_snapshot_job_id, ios_app_id: app_identifier)}.first

        next if !snapshot.present?

        next if !(snapshot.status == 'complete' || snapshot.status == 'cleaning')

        result = snapshot

        break if result || Time.now - start > 90 # 90 seconds
      end

      if result.nil? || !result.success
        # not sure, just exit
        return "Failure or Timeout. Check IpaSnapshotException table"
      end


      # normally would kick off a service to analyze it but for now just throw data into results table
      matches = IosSdk.select(:id).sample(5)
      matches.each do |sdk|
        IosSdksIpaSnapshot.create!(ipa_snapshot_id: result.id, ios_sdk_id: sdk.id)
      end
    else
      nil # mass scrape not implemented yet
    end
  end
end