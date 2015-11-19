class IosLiveScanServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, queue: :ios_live_scan

  def perform(ipa_snapshot_job_id, ios_app_id)

    job = IpaSnapshotJob.find(ipa_snapshot_job_id)
    # if it's available
    data = get_json(ios_app_id)

    if data.nil?
      job.live_scan_status = :not_available
      job.save
      return "Not available"
    end

    # if it's been changed
    # In development mode, just scan it
    if Rails.env.production? && !should_update(ios_app_id: ios_app_id, version: data['version'])
      job.live_scan_status = :unchanged
      job.save
      IosApp.find(ios_app_id)
      return "App has not updated"
    end

    # check if devices compatible
    if !device_compatible(data['devices'])
      job.live_scan_status = :device_incompatible
      job.save
      return "No compatible devices available"
    end

    job.live_scan_status = :initiated
    job.save

    if Rails.env.production?

      batch = Sidekiq::Batch.new
      batch.description = "running a live scan job"
      bid = batch.bid

      batch.jobs do
        IosScanSingleServiceWorker.perform_async(ipa_snapshot_job_id, ios_app_id, bid)
      end
    else
      IosScanSingleServiceWorker.new.perform(ipa_snapshot_job_id, ios_app_id)
    end

    # TODO: add an exceptions table
  end

  def device_compatible(devices: devices)
    # TODO: implement
    true
  end

  def should_update(ios_app_id:, version:)
    last_snap = IosApp.find(ios_app_id).get_last_ipa_snapshot(success: true)

    if !version.blank? && !(last_snap.nil? || last_snap.version.nil?) && version <= last_snap.version
      last_snap.touch # update the ipa snapshot with current date
      false
    else
      true 
    end
  end

  def get_json(ios_app_id)
    begin
      # app_identifier = IosApp.find(ios_app_id).app_identifier # TODO, uncomment this
      app_identifier = ios_app_id
      url = "https://itunes.apple.com/lookup?id=#{app_identifier.to_s}&uslimit=1"

      json = JSON.parse(Proxy.get_body_from_url(url))

      json['results'].first
    rescue
      nil
    end
  end

end