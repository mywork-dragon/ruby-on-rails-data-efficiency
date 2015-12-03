class IosLiveScanServiceWorker

  include Sidekiq::Worker

  # retrying the json lookup ourselves, so disable
  sidekiq_options backtrace: true, retry: false, queue: :ios_live_scan_cloud

  LOOKUP_ATTEMPTS = 2

  def perform(ipa_snapshot_job_id, ios_app_id)

    begin
      puts "#{ipa_snapshot_job_id}: Starting validation #{Time.now}"
      job = IpaSnapshotJob.find(ipa_snapshot_job_id)
      data = get_json(ios_app_id)

      raise "Could not perform iTunes lookup for app #{ios_app_id}" if data.nil?

      data = data['results'].first

      if data.nil?
        job.live_scan_status = :not_available
        job.save

        IosApp.find(ios_app_id).update(display_type: :taken_down) # not entirely correct...could be foreign
        return "Not available"
      end

      if data['price'].to_f > 0
        job.live_scan_status = :paid
        job.save
        return "Cannot scan paid app"     
      end

      # if it's been changed (for now, just ignore that stuff)
      if false
        # if Rails.env.production? && !should_update(ios_app_id: ios_app_id, version: data['version'])
        job.live_scan_status = :unchanged
        job.save
        IosApp.find(ios_app_id)
        return "App has not updated"
      end

      # check if devices compatible
      if !device_compatible?(devices: data['supportedDevices'])
        job.live_scan_status = :device_incompatible
        job.save

        IosApp.find(ios_app_id).update(display_type: :device_incompatible)
        return "No compatible devices available"
      end

      puts "#{ipa_snapshot_job_id}: Finished validation #{Time.now}"

      if Rails.env.production?

        batch = Sidekiq::Batch.new
        batch.description = "running a live scan job"
        bid = batch.bid

        batch.jobs do
          if job.job_type == 'one_off'
            IosScanSingleServiceWorker.perform_async(ipa_snapshot_job_id, ios_app_id, bid)
          elsif job.job_type == 'test'
            IosScanSingleTestWorker.perform_async(ipa_snapshot_job_id, ios_app_id, bid)
          end
        end
      else
        if job.job_type == 'one_off'
          IosScanSingleServiceWorker.new.perform(ipa_snapshot_job_id, ios_app_id, bid)
        elsif job.job_type == 'test'
          IosScanSingleTestWorker.new.perform(ipa_snapshot_job_id, ios_app_id, bid)
        end
      end

      job.live_scan_status = :initiated
      job.save

    rescue => e
      IpaSnapshotJobException.create!({
        ipa_snapshot_job_id: ipa_snapshot_job_id,
        error: e.message,
        backtrace: e.backtrace
        })

      if !job.nil?
        job.live_scan_status = :failed
        job.save
      end
    end
  end


  # Are all devices compatible?
  # @author Jason Lew
  def device_compatible?(devices: devices)
    available_devices = IosDeviceFamily.uniq.pluck(:lookup_name).compact
    (available_devices - devices).empty? # whether all available devices support the app
  end

  def should_update(ios_app_id:, version:)
    last_snap = IosApp.find(ios_app_id).get_last_ipa_snapshot(scan_success: true)

    if !version.blank? && !(last_snap.nil? || last_snap.version.nil?) && version <= last_snap.version
      last_snap.touch # update the ipa snapshot with current date
      false
    else
      true 
    end
  end

  def get_json(ios_app_id)

    data = nil

    LOOKUP_ATTEMPTS.times do |i|
      begin
        app_identifier = IosApp.find(ios_app_id).app_identifier # TODO, uncomment this
        url = "https://itunes.apple.com/lookup?id=#{app_identifier.to_s}&uslimit=1"

        data = JSON.parse(Proxy.get_body_from_url(url))
        
      rescue => e
        nil
      end

      break if data.present?  
    end

    data
  end

end