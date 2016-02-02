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
          version = :json_dump
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

      elsif version == :json_dump
        json_dump = apk_file.json_dump
        raise NoJsonDump if !json_dump.exists?
        json_dump_file = open(json_dump.url)

        classify(json_dump_file)
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

  def classify
    parser = Yajl::Parser.new
    json = parser.parse(json_dump_file)

    # the order matters here
    classify_js_tags(json)
    classify_dlls(json)
    classify_dex_classes(json)
  end

  def classify_dex_classes(json)
    classes = json['dex_classes']

    packages = []

    packages = classes.each.map |c|
      next if c.blank? || c.downcase.include?(app_identifier.split('.')[1].downcase)

      package = c.name.split('/')  # split by /
      package.pop   #remove last

      package.sub!(/\AL/, '') # remove leading L

      package.join('.')
    end.compact.uniq

    b = Benchmark.measure do 
      android_sdk_service = AndroidSdkService.new(jid: self.jid, proxy_type: proxy_type)  # proxy_type is a method on the classes that import this module
      android_sdk_service.classify(snap_id: snap_id, packages: packages)
    end

    puts "#{snap_id}: Classify Time: #{b.real}"

    true
  end

  def classify_js_tags(json)
  end

  def classify_dlls(json)
  end

  class NoJsonDump < StandardError

    def initialize(message = "A JSON dump does not exist for this ApkFile.")
      super
    end

  end

end