module IosCloud
  class NoRegisteredStores; end
  LOOKUP_ATTEMPTS = 2

  def perform(ipa_snapshot_job_id, ios_app_id)
    @ipa_snapshot_job = IpaSnapshotJob.find(ipa_snapshot_job_id)
    @ios_app = IosApp.find(ios_app_id)

    puts "#{ipa_snapshot_job_id}: Starting validation #{Time.now}"
    lookup_result = get_json(ios_app_id)

    if lookup_result == NoRegisteredStores
      log_result(ipa_snapshot_job_id:ipa_snapshot_job_id, ios_app_id:ios_app_id, reason: :no_stores, data: nil)
      return no_stores
    elsif lookup_result == ItunesApi::EmptyResult
      log_result(ipa_snapshot_job_id:ipa_snapshot_job_id, ios_app_id:ios_app_id, reason: :no_data, data: nil)
      return no_data(ipa_snapshot_job_id, ios_app_id, international: allow_international?)
    end

    data = lookup_result['results'].first

    if !is_ios?(data)
      log_result(ipa_snapshot_job_id:ipa_snapshot_job_id, ios_app_id:ios_app_id, reason: :not_ios, data: data)
      return not_ios(ipa_snapshot_job_id, ios_app_id)
    end

    if data['price'].to_f > 0
      log_result(ipa_snapshot_job_id:ipa_snapshot_job_id, ios_app_id:ios_app_id, reason: :paid, data: data)
      return paid_app(ipa_snapshot_job_id, ios_app_id)
    end

    version = data['version']

    if allow_update_check?(ipa_snapshot_job_id, ios_app_id) && !should_update(ios_app_id: ios_app_id, version: version)
      log_result(ipa_snapshot_job_id:ipa_snapshot_job_id, ios_app_id:ios_app_id, reason: :unchanged, data: data)
      return no_update_required(ipa_snapshot_job_id, ios_app_id)
    end

    if !device_compatible?(devices: data['supportedDevices'])
      log_result(ipa_snapshot_job_id:ipa_snapshot_job_id, ios_app_id:ios_app_id, reason: :device_incompatible, data: data)
      return not_device_compatible(ipa_snapshot_job_id, ios_app_id)
    end

    puts "#{ipa_snapshot_job_id}: Finished validation #{Time.now}"

    snapshot = IpaSnapshot.create!(ipa_snapshot_job_id: ipa_snapshot_job_id, ios_app_id: ios_app_id, version: version, lookup_content: data.to_json, app_store_id: lookup_result[:app_store_id])

    start_job(ipa_snapshot_job_id, ios_app_id, snapshot.id)

  rescue => e
    IpaSnapshotJobException.create!(
      ipa_snapshot_job_id: ipa_snapshot_job_id,
      ios_app_id: ios_app_id,
      error: e.message,
      backtrace: e.backtrace
    )
    handle_error(error: e, ipa_snapshot_job_id: ipa_snapshot_job_id, ios_app_id: ios_app_id)
  end

  # Are all devices compatible?
  # @author Jason Lew
  def device_compatible?(devices:)
    available_devices = IosDeviceFamily.uniq.pluck(:lookup_name).compact
    (available_devices - devices).empty? # whether all available devices support the app
  end

  def should_update(ios_app_id:, version:)
    last_snap = IosApp.find(ios_app_id).get_last_ipa_snapshot(scan_success: true)

    return true if version.blank? || last_snap.nil? || last_snap.version.nil? || last_snap.version.chomp != version.chomp

    last_snap.good_as_of_date = Time.now
    last_snap.save
    false
  end

  def is_ios?(data)
    # wrapper type software
    # kind == 'software' (as opposed to mac-software)
    return false if data['wrapperType'] != 'software'
    return false if data['kind'] != 'software'
    true
  end

  def log_result(ipa_snapshot_job_id:, ios_app_id:, reason:, data: nil)
    IpaSnapshotLookupFailure.create!({
      ipa_snapshot_job_id: ipa_snapshot_job_id,
      ios_app_id: ios_app_id,
      reason: reason,
      lookup_content: data.to_json
    })
  end

  def no_stores
    @ipa_snapshot_job.update!(live_scan_status: :not_available)
  end

  def get_json(ios_app_id)
    allow_international? ? international_lookup(ios_app_id) : us_only_lookup(ios_app_id)
  end

  def us_only_lookup(ios_app_id)
    app_identifier = IosApp.find(ios_app_id).app_identifier
    res = ItunesApi.lookup_app_info(app_identifier)
    return res if res == ItunesApi::EmptyResult
    res[:app_store_id] = AppStore.find_by_country_code!('us').id
    res
  end

  def international_lookup(ios_app_id)
    app_identifier = IosApp.find(ios_app_id).app_identifier

    stores = AppStore.joins(:ios_apps)
      .where('ios_apps.id = ?', ios_app_id)
      .where(enabled: true, tos_valid: true).where.not(priority: nil)
      .order(:priority)

    # Could be timing issue where trying to scrape ios app that hasn't been checked internationally
    return NoRegisteredStores unless stores.present?

    res = nil
    available_store = stores.find do |store| # need to do limiting later when get more stores
      res = ItunesApi.lookup_app_info(
        app_identifier,
        country_code: store.country_code.downcase
      )
      res == ItunesApi::EmptyResult ? false : true
    end

    return ItunesApi::EmptyResult unless available_store

    res[:app_store_id] = available_store.id
    res
  end
end


