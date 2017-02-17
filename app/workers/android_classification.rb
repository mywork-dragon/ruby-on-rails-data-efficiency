module AndroidClassification
  class NoApkFile < RuntimeError; end

  def perform(apk_snapshot_id)
    @apk_snapshot = ApkSnapshot.find(apk_snapshot_id)
    log "Starting classification for snapshot #{@apk_snapshot.id}"

    # Don't fiddle with the status of
    # scans which have already completed once.
    update_scan_status(:scanning) if not rescan

    classify
    update_scan_status(:scan_success)
    log_activities if Rails.env.production? and not rescan
    log "Completed classification for snapshot #{@apk_snapshot.id}"

  rescue => e
    log "Failed classification for snapshot #{@apk_snapshot.id}"
    ApkSnapshotException.create!(
      name: e.message,
      backtrace: e.backtrace,
      apk_snapshot_id: apk_snapshot_id
    )

    # Don't fiddle with the status of
    # scans which have already completed once.
    update_scan_status(:scan_failure) if not rescan

    raise e
  ensure
    @apk_snapshot.android_app.update_newest_apk_snapshot
  end

  def rescan
    @apk_snapshot.status != nil
  end

  def unique_id
    @apk_snapshot.id
  end

  def log(message)
    puts "#{unique_id}: #{message}"
  end

  def update_scan_status(status)
    info = {
      scan_status: status,
      last_updated: DateTime.now
    }
    info.merge!({ last_scanned: DateTime.now }) if status == :scan_success
    @apk_snapshot.update!(info)
  end

  def classify
    sdks, paths = classify_classes
    rows = sdks.map do |sdk|
      AndroidSdksApkSnapshot.new(
          apk_snapshot_id: @apk_snapshot.id,
          android_sdk_id: sdk.id,
          method: :classes
        )
    end
    # Atomically delete existing sdk classification relations
    # and insert the new ones.
    AndroidSdksApkSnapshot.where(apk_snapshot_id: @apk_snapshot.id).delete_all
    AndroidSdksApkSnapshot.import rows
    @apk_snapshot.store_classification_summary(paths)
  end

  def log_activities
    ActivityWorker.perform_async(:log_android_sdks, @apk_snapshot.android_app_id)
  end


  def classify_classes
    classes = @apk_snapshot.apk_file.classes
    sdks, paths = SdkService.find_or_create_android_sdks_from_classes(
      classes: classes,
      read_only: false
    )

    [sdks, paths]
  end

end
