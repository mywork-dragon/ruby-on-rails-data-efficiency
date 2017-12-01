module AndroidCloud

  def perform(apk_snapshot_job_id, android_app_id)
    @apk_snapshot_job = ApkSnapshotJob.find(apk_snapshot_job_id)
    @android_app = AndroidApp.find(android_app_id)
    puts "#{apk_snapshot_job_id}: Starting validation #{Time.now}"
    return 'Invalid Job' unless valid_job?
    start_job
  rescue => e
    @apk_snapshot_job.update!(
      ls_lookup_code: :failed
    ) if update_live_scan_job_codes? && @apk_snapshot_job
    ApkSnapshotScrapeException.create!(
      apk_snapshot_job_id: apk_snapshot_job_id,
      android_app_id: android_app_id,
      error: e.message,
      backtrace: e.backtrace
    )
    raise e
  end

  def valid_job?
    unless is_available?
      return false
    end

    if is_paid?
      handle_paid
      return false
    end

    if allow_update_check? && !should_update?
      handle_unchanged
      return false
    end

    true
  end

  # checks if app is still available in the play store
  # side effect: sets attributes instance variable
  def is_available?
    @attributes = GooglePlayService.attributes(@android_app.app_identifier)
    true
  rescue GooglePlayStore::NotFound
    handle_not_found
    false
  rescue GooglePlayStore::Unavailable
    handle_unavailable
    false
  end

  def is_paid?
    @attributes[:price] != 0
  end

  def allow_update_check?
    Rails.env.production?
  end

  def should_update?
    scrape_version = @attributes[:version]
    last_scan_version = @android_app.newest_apk_snapshot.version if @android_app.newest_apk_snapshot_id # latest_snapshot_could_not_exist

    return true if scrape_version.nil? || last_scan_version.nil? || scrape_version.match(/Varies/i)

    scrape_version != last_scan_version
  end

  def handle_unavailable
    log_result(reason: :unavailable)
    @android_app.update!(display_type: :taken_down)
    @apk_snapshot_job.update!(ls_lookup_code: :unavailable) if update_live_scan_job_codes?
  end

  def handle_not_found
    log_result(reason: :not_found)
    @android_app.update!(display_type: :taken_down)
    @apk_snapshot_job.update!(ls_lookup_code: :unavailable) if update_live_scan_job_codes?
  end

  def handle_paid
    log_result(reason: :paid)
    @android_app.update!(display_type: :paid)
    @apk_snapshot_job.update!(ls_lookup_code: :paid) if update_live_scan_job_codes?
  end

  def handle_unchanged
    log_result(reason: :unchanged_version)
    @android_app.newest_apk_snapshot.update!(good_as_of_date: Time.now)
    @apk_snapshot_job.update!(ls_lookup_code: :unchanged) if update_live_scan_job_codes?
  end

  def log_result(reason:)
    ApkSnapshotScrapeFailure.create!(
      android_app_id: @android_app.id,
      apk_snapshot_job_id: @apk_snapshot_job.id,
      reason: reason,
      scrape_content: @attributes
    )
  end
end
