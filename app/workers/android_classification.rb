module AndroidClassification
  class NoApkFile < RuntimeError; end

  def perform(apk_snapshot_id)
    @apk_snapshot = ApkSnapshot.find(apk_snapshot_id)
    log 'Starting'
    update_scan_status(:scanning)
    classify
    update_scan_status(:scan_success)
    log_activities if Rails.env.production?
    log 'Complete'
  rescue => e
    ApkSnapshotException.create!(
      name: e.message,
      backtrace: e.backtrace,
      apk_snapshot_id: apk_snapshot_id
    )
    log 'Failed'
    update_scan_status(:scan_failure)
    raise e
  ensure
    @apk_snapshot.android_app.update_newest_apk_snapshot
  end 

  def dump_directory
    Rails.env.production? ? '/mnt/apk_files' : '/tmp'
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
    zip_path = File.join(dump_directory, "#{unique_id}.zip")
    download_stored_apk(zip_path)
    classify_all_sources
  ensure
    FileUtils.rm_rf(@apk_path) if @apk_path
  end

  # Use open-uri instead of HTTParty for binary-downloading related reasons
  def download_stored_apk(path)
    log 'Downloading APK'
    apk_file = @apk_snapshot.apk_file
    raise NoApkFile unless apk_file
    url = apk_file.zip? ? apk_file.zip.url : apk_file.apk.url # v1 - whole apk. v2 - subset of apk
    File.open(path, 'wb') do |dest_fd|
      open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE) do |src_fd|
        IO.copy_stream(src_fd, dest_fd)
      end
    end
    @apk_path = path
  end
  
  def log_activities
    ActivityWorker.perform_async(:log_android_sdks, @apk_snapshot.android_app_id)
  end

  def classify_all_sources
    raise NotDownloaded unless @apk_path && File.exist?(@apk_path)
    setup_store
    classify_from_zipped
    classify_from_unzipped
    commit_store
  end

  def classify_from_unzipped
    return unless classify_sources?(:js_tag_regexes, :dll_regexes)
    Zipper.unzip(@apk_path) do |unzipped_path|
      js_tag_sdks = classify_sources?(:js_tag_regexes) ? classify_js_tags(unzipped_path) : []
      dll_sdks = classify_sources?(:dll_regexes) ? classify_dlls(unzipped_path) : []

      add_to_store(js_tag_sdks, :js_tag_regexes)
      add_to_store(dll_sdks, :dll_regexes)
    end
  end

  def setup_store
    @store = {}
  end

  def add_to_store(sdks, method)
    existing = @store[method]
    @store[method] = existing.present? ? (sdks + existing).uniq : sdks
  end

  def commit_store
    rows = @store.map do |method, sdks|
      sdks.map do |sdk|
        AndroidSdksApkSnapshot.new(
          apk_snapshot_id: @apk_snapshot.id,
          android_sdk_id: sdk.id,
          method: method
        )
      end
    end.flatten

    AndroidSdksApkSnapshot.import rows
  end

  def classify_from_zipped
    package_sdks = classify_sources?(:packages) ? classify_packages : []
    add_to_store(package_sdks, :packages)
  end

  def classify_packages
    log 'Starting packages'
    packages = packages_from_zipped
    sdks = SdkService.find_from_packages(
      packages: packages,
      platform: :android,
      snapshot_id: @apk_snapshot.id
    )
    log 'Finished packages'
    sdks
  end

  def packages_from_zipped
    dex = Android::Apk.new(@apk_path).dex
    classes = dex.present? ? dex.classes.map(&:name) : []
    app_identifier = @apk_snapshot.android_app.app_identifier
    ignore_regex = /#{app_identifier.split('.')[1].downcase}/i
    classes.map do |c|
      next if c.blank? || ignore_regex.match(c)
      c.sub!(/\AL/, '') # remove leading L
      package = c.split('/')  # split by /
      package.pop   #remove last
      package.join('.')
    end.compact.uniq
  end

  # override later for reclassification
  # allow for turning on/off different sources
  def classify_sources?(*sources)
    true
  end

  # returns an array of SDKs
  def classify_js_tags(unzipped_path)
    log 'Starting JS Tags'
    js_tags = js_tags_from_unzipped_apk(unzipped_path)
    store_js_tags(js_tags)

    combined = js_tags.join("\n")

    sdk_ids = JsTagRegex.where.not(android_sdk_id: nil).map do |regex_row|
      regex_row.android_sdk_id if regex_row.regex.match(combined)
    end

    log 'Finished JS Tags'
    AndroidSdk.where(id: sdk_ids)
  end

  def js_tags_from_unzipped_apk(unzipped_path)
    # read directly from files
    js_includes = Dir.glob(File.join(unzipped_path, 'assets/www', '**/*')).map do |entry|
      begin
        File.open(entry, 'r') do |f|
          f.read.scan(/<script src=[\S]+\/([\S]+\.js)/)
        end
      rescue
        nil
      end
    end.flatten.compact

    js_files = Dir.glob(File.join(unzipped_path, '**/*.js')).map do |entry|
      File.basename(entry)
    end

    (js_includes + js_files).uniq.map do |tag|
      DbSanitizer.truncate_string(tag)
    end
  end

  def classify_dlls(unzipped_path)
    log 'Starting Dlls'
    dlls = dlls_from_unzipped_apk(unzipped_path)
    store_dlls(dlls)

    combined = dlls.join("\n")
    sdk_ids = DllRegex.where.not(android_sdk_id: nil).map do |regex_row|
      regex_row.android_sdk_id if regex_row.regex.match(combined)
    end

    log 'Finished Dlls'
    AndroidSdk.where(id: sdk_ids)
  end

  def dlls_from_unzipped_apk(unzipped_path)
    Dir.glob(File.join(unzipped_path, 'META-INF', '*.{MF,SF}')).map do |file|
      begin
        File.open(file, 'r') do |f|
          f.read.scan(/Name: \S+\/(\S+\.dll)/)
        end
      rescue
        nil
      end
    end.flatten.compact.map do |dll|
      DbSanitizer.truncate_string(dll)
    end.uniq
  end

  def store_dlls(dlls)
    existing = SdkDll.where(name: dlls)
    existing_names = existing.pluck(:name).map(&:downcase)
    missing = dlls.select { |t| !existing_names.include?(t.downcase) } # account for case-insensitive index
    rows = missing.map { |t| SdkDll.new(name: t) }
    SdkDll.import(
      rows,
      synchronize: rows,
      synchronize_keys: [:name]
    )

    join_rows = (existing + rows).map do |sdk_dll|
      ApkSnapshotsSdkDll.new(
        apk_snapshot_id: @apk_snapshot.id,
        sdk_dll_id: sdk_dll.id
      )
    end

    ApkSnapshotsSdkDll.import(join_rows)
  end

  def store_js_tags(tags)
    existing = SdkJsTag.where(name: tags)
    existing_names = existing.pluck(:name).map(&:downcase)
    missing = tags.select { |t| !existing_names.include?(t.downcase) } # account for case-insensitive index
    rows = missing.map { |t| SdkJsTag.new(name: t) }
    SdkJsTag.import(
      rows,
      synchronize: rows,
      synchronize_keys: [:name]
    )

    join_rows = (existing + rows).map do |sdk_js_tag|
      ApkSnapshotsSdkJsTag.new(
        apk_snapshot_id: @apk_snapshot.id,
        sdk_js_tag_id: sdk_js_tag.id
      )
    end

    ApkSnapshotsSdkJsTag.import(join_rows)
  end
end
