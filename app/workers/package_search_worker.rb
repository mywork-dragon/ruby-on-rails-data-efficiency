module PackageSearchWorker

  def perform(app_id)
    aa = AndroidApp.find(app_id)
    app_identifier = aa.app_identifier
    snap_id = aa.newest_apk_snapshot_id
    return nil if snap_id.blank?
    find_packages(app_identifier: app_identifier, snap_id: snap_id)
  end

  def find_packages(app_identifier:, snap_id:)

    apk = nil
    apk_snap = nil
    packages = nil
    s3_file = nil

    
    begin
      if Rails.env.production?
        apk_snap = ApkSnapshot.find(snap_id)
        apk_file = apk_snap.apk_file

        if apk_file.apk.exists?   # old version, where the ENTIRE APK was stored...
          version = :apk
          file_name = apk_snap.apk_file.apk.url
          file_size = apk_snap.apk_file.apk.size
          b = Benchmark.measure { 
          s3_file = open(file_name)}
          c = Benchmark.measure {
          apk = Android::Apk.new(s3_file)}
        else
          version = :zip
        end
      elsif Rails.env.development?
        raise "Not implemented yet"
      end

      if version == :apk
        dex = apk.dex
        packages = dex.classes.map do |cls|
          next if cls.name.blank? || cls.name.downcase.include?(app_identifier.split('.')[1].downcase)
          cls = cls.name.split('/')
          cls.pop
          cls = cls.join('.')
          cls.slice!(0) if cls.slice(0) == 'L'
          cls
        end.compact.uniq


        b = Benchmark.measure do 
          android_sdk_service = AndroidSdkService.new(jid: self.jid, proxy_type: proxy_type)  # proxy_type is a method on the classes that import this module
          android_sdk_service.classify(snap_id: snap_id, packages: packages)
        end

        puts "#{snap_id}: Classify Time: #{b.real}"

      elsif version == :zip
        zip = apk_file.zip
        raise NoJsonDump if !zip.exists?
        zip_file = File.open(zip)
        classify(zip_file: zip_file, android_app: aa, apk_ss: apk_snap)
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
    end

  end

  def classify(zip_file:, android_app:, apk_ss)

    unzipped_apk = Zip::File.open(zip_file)

    classify_js_tags(unzipped_apk: unzipped_apk, android_app: android_app, apk_ss: apk_snap)
    #classify_dlls(unzipped_apk: unzipped_apk, android_app: android_app, apk_ss: apk_snap)
    # classify_dex_classes(zip_file: zip_file, android_app: android_app, apk_ss: apk_snap)
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
      android_sdk_service.classify(snap_id: apk_ss, packages: packages)
    end

    puts "#{snap_id}: Classify Time: #{b.real}"

    true
  end

  def classify_js_tags(unzipped_apk:, android_app:, apk_ss)
    js_tags = js_tags(unzipped_apk: unzipped_apk, android_app: android_app)

    js_tags_s = js_tags.join("\n")

    JsTagRegex.find_in_batches(batch_size: 1000).with_index do |batch, index|
      batch.each do |js_tag_regex|
        regex = Regexp.new(js_tag_regex.regex)
        if js_tags_s.match(regex)
          puts "match #{regex}"
          AndroidSdksApkSnapshot.create!(android_sdk: js_tag_regex.android_sdk, apk_snapshot: apk_snapshot)
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

  def classify_dlls(unzipped_apk:, android_app:, apk_ss: apk_snap)
    dlls(unzipped_apk: unzipped_apk, android_app: android_app)
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

end