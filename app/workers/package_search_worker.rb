module PackageSearchWorker

  def perform(app_id)
    aa = AndroidApp.find(app_id)
    app_identifier = aa.app_identifier
    snap_id = aa.newest_apk_snapshot_id
    return nil if snap_id.blank?
    find_packages(app_identifier: app_identifier, snap_id: snap_id, android_app: aa)
  end

  def find_packages(app_identifier:, snap_id:, android_app:)

    apk = nil
    apk_snap = nil
    packages = nil
    s3_file = nil

    
    begin
      if Rails.env.production?
        apk_snap = ApkSnapshot.find(snap_id)
        apk_file = apk_snap.apk_file

        puts "apk_snap: #{apk_snap}"
        puts "apk_file: #{apk_file}"

        if apk_file.apk?  # old version, where the ENTIRE APK was stored...
          puts "version: :apk"
          version = :apk
        else
          version = :zip
        end
      elsif Rails.env.development?
        raise "Not implemented yet"
      end

      if version == :apk
        zip_file = open(apk_file.apk.url)
        puts "opened"
        classify(zip_file: zip_file, android_app: android_app, apk_ss: apk_snap)
      elsif version == :zip
        raise NoZip unless apk_file.zip?
        zip_file = open(apk_file.zip.url)
        classify(zip_file: zip_file, android_app: android_app, apk_ss: apk_snap)
      end
      
    rescue => e
      ase = ApkSnapshotException.create!(name: e.message, backtrace: e.backtrace, apk_snapshot: apk_snap)
      
      apk_snap.scan_status = :scan_failure
      apk_snap.last_updated = DateTime.now
      apk_snap.save!
    else
      apk_snap.scan_status = :scan_success
      apk_snap.last_updated = DateTime.now
      apk_snap.save!
    ensure
      zip_file.close if defined?(zip_file)
    end

  end

  def classify(zip_file:, android_app:, apk_ss:)

    puts "classify"

    unzipped_apk = Zip::File.open(zip_file)

    puts "unzipped_apk"

    puts "#0"

    classify_js_tags(unzipped_apk: unzipped_apk, android_app: android_app, apk_ss: apk_ss)
    puts "#1"
    classify_dlls(unzipped_apk: unzipped_apk, android_app: android_app, apk_ss: apk_ss)
    puts "#2"
    classify_dex_classes(zip_file: zip_file, android_app: android_app, apk_ss: apk_ss)

    puts "done classifying"
  end

  def classify_dex_classes(zip_file:, android_app:, apk_ss:)
    apk = Android::Apk.new(zip_file)
    dex = apk.dex
    classes = dex.classes.map(&:name)

    packages = []

    packages = classes.each.map do |c|
      next if c.blank? || c.downcase.include?(android_app.app_identifier.split('.')[1].downcase)

      c.sub!(/\AL/, '') # remove leading L

      package = c.split('/')  # split by /
      package.pop   #remove last

      package.join('.')
    end.compact.uniq

    b = Benchmark.measure do 
      android_sdk_service = AndroidSdkService.new(jid: self.jid, proxy_type: proxy_type)  # proxy_type is a method on the classes that import this module
      android_sdk_service.classify(snap_id: apk_ss.id, packages: packages)
    end

    puts "#{apk_ss.id}: Classify Time: #{b.real}"

    true
  end

  def classify_js_tags(unzipped_apk:, android_app:, apk_ss:)
    js_tags = js_tags(unzipped_apk: unzipped_apk, android_app: android_app)

    # Put all tags in sdk_js_tags
    js_tags.each do |js_tag|
      sdk_js_tag = SdkJsTag.find_by_name(js_tag)

      if sdk_js_tag.nil?
        begin
          sdk_js_tag = SdkJsTag.create!(name: js_tag)
        rescue ActiveRecord::RecordNotUnique => e
          puts "Tag already exists for #{js_tag}"
          sdk_js_tag = SdkJsTag.find_by_name(js_tag)
        end
      end

      # Put entry in apk_snapshots_sdk_js_tags join table
      ApkSnapshotsSdkJsTag.create!(apk_snapshot: apk_ss, sdk_js_tag: sdk_js_tag)

    end

    js_tags_s = js_tags.join("\n")

    JsTagRegex.find_in_batches(batch_size: 1000).with_index do |batch, index|
      batch.each do |js_tag_regex|
        regex = js_tag_regex.regex
        if js_tags_s.match(regex)
          puts "match #{regex}"
          unless AndroidSdksApkSnapshot.where(android_sdk: js_tag_regex.android_sdk, apk_snapshot: apk_ss).present?
            AndroidSdksApkSnapshot.create!(android_sdk: js_tag_regex.android_sdk, apk_snapshot: apk_ss)
          end
        end
      end
    end
  end

  def js_tags(unzipped_apk:, android_app:)
    entries = unzipped_apk.glob('assets/www/*')
    js_tags = entries.map do |entry|
      contents = entry.get_input_stream.read
      contents.scan(/<script src=.*\/(.*.js)/)
    end.flatten.compact

    js_files = []

    unzipped_apk.each do |entry|
      basename = File.basename(entry.name.chomp)
      next unless basename.match(/.js\z/)
      js_files << basename 
    end

    (js_tags + js_files).uniq
  end

  def classify_dlls(unzipped_apk:, android_app:, apk_ss:)
    dlls = dlls(unzipped_apk: unzipped_apk, android_app: android_app)

    # Put all tags in sdk_dlls
    dlls.each do |dll|
      sdk_dll = SdkDll.find_by_name(dll)

      if sdk_dll.nil?
        begin
          sdk_dll = SdkDll.create!(name: dll)
        rescue ActiveRecord::RecordNotUnique => e
          puts "Tag already exists for #{dll}"
          sdk_dll = SdkJsTag.find_by_name(dll)
        end
      end

      # Put entry in apk_snapshots_sdk_js_tags join table
      ApkSnapshotsSdkDll.create!(apk_snapshot: apk_ss, sdk_dll: sdk_dll)

    end

    dlls_s = dlls.join("\n")

    DllRegex.find_in_batches(batch_size: 1000).with_index do |batch, index|
      batch.each do |dll_regex|
        regex = dll_regex.regex
        if dlls_s.match(regex)
          puts "match #{regex}"
          unless AndroidSdksApkSnapshot.where(android_sdk: dll_regex.android_sdk, apk_snapshot: apk_ss).present?
            AndroidSdksApkSnapshot.create!(android_sdk: dll_regex.android_sdk, apk_snapshot: apk_ss)
          end
        end
      end
    end

  end

  def dlls(unzipped_apk:, android_app:)
    files = [unzipped_apk.glob('META-INF/*.SF').first, unzipped_apk.glob('META-INF/*.MF').first].compact
    files.map do |file|
      contents = file.get_input_stream.read
      contents.scan(/Name: .*\/(.*.dll)/).flatten
    end.flatten.compact.uniq
  end

  class NoZip < StandardError

    def initialize(message = "A Zip does not exist for this ApkFile.")
      super
    end

  end

  class NoApk < StandardError

    def initialize(message = "An APK does not exist for this ApkFile.")
      super
    end

  end

end