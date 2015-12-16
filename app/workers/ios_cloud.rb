module IosCloud

  LOOKUP_ATTEMPTS = 2

  def perform(ipa_snapshot_job_id, ios_app_id)

    begin
      puts "#{ipa_snapshot_job_id}: Starting validation #{Time.now}"
      job = IpaSnapshotJob.find(ipa_snapshot_job_id)
      data = get_json(ios_app_id)

      raise "Could not perform iTunes lookup for app #{ios_app_id}" if data.nil?

      data = data['results'].first

      return no_data(ipa_snapshot_job_id, ios_app_id) if data.nil?

      return not_ios(ipa_snapshot_job_id, ios_app_id) if !is_ios?(data)

      return paid_app(ipa_snapshot_job_id, ios_app_id) if data['price'].to_f > 0

      version = data['version']
      return no_update_required(ipa_snapshot_job_id, ios_app_id) if allow_update_check?(ipa_snapshot_job_id, ios_app_id) && !should_update(ios_app_id: ios_app_id, version: version)

      return not_device_compatible(ipa_snapshot_job_id, ios_app_id) if !device_compatible?(devices: data['supportedDevices'])

      puts "#{ipa_snapshot_job_id}: Finished validation #{Time.now}"

      snapshot = IpaSnapshot.create!(ipa_snapshot_job_id: ipa_snapshot_job_id, ios_app_id: ios_app_id, version: version, lookup_content: data.to_json)

      start_job(ipa_snapshot_job_id, ios_app_id, snapshot.id)

    rescue => e
      IpaSnapshotJobException.create!({
        ipa_snapshot_job_id: ipa_snapshot_job_id,
        ios_app_id: ios_app_id,
        error: e.message,
        backtrace: e.backtrace
        })
      handle_error(error: e, ipa_snapshot_job_id: ipa_snapshot_job_id, ios_app_id: ios_app_id)
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
      last_snap.good_as_of_date = Time.now # update the ipa snapshot with current date
      last_snap.save
      false
    else
      true 
    end
  end

  def is_ios?(data)
    # wrapper type software
    # kind == 'software' (as opposed to mac-software)
    return false if data['wrapperType'] != 'software'
    return false if data['kind'] != 'software'
    true
  end

  def get_json(ios_app_id)

    data = nil

    LOOKUP_ATTEMPTS.times do |i|
      begin
        app_identifier = IosApp.find(ios_app_id).app_identifier 
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