module PackageSearchWorker

  def perform(app_id)
    aa = AndroidApp.find(app_id)
    app_identifier = aa.app_identifier
    snap_id = aa.newest_apk_snapshot_id
    return nil if snap_id.blank?
    find_packages(app_identifier: app_identifier, snap_id: snap_id)
  end

  def find_packages(app_identifier:, snap_id:)

    b = Benchmark.measure { 
      if Rails.env.production?
      apk_snap = ApkSnapshot.find(snap_id)
      file_name = apk_snap.apk_file.apk.url
      s3_file = open(file_name)
      apk = Android::Apk.new(s3_file)
    elsif Rails.env.development?
      file_name = '../../Documents/sample_apps/' + app_identifier + '.apk'
      apk = Android::Apk.new(file_name)
    end }

    puts "#{snap_id}: Download time: #{b.real}"

    # puts "#{snap_id} => downloaded [#{a.real}]"

    b = Benchmark.measure {
    dex = apk.dex
    packages = dex.classes.map do |cls|
      next if cls.name.blank? || cls.name.downcase.include?(app_identifier.split('.')[1].downcase)
      cls = cls.name.split('/')
      cls.pop
      cls = cls.join('.')
      cls.slice!(0) if cls.slice(0) == 'L'
      cls
    end.compact.uniq}

    puts "#{snap_id}: Dex mapping time: #{b.real}"


    b = Benchmark.measure {AndroidSdkService.classify(snap_id: snap_id, packages: packages)}

    puts "#{snap_id}: Classify Time: #{b.real}"

    # apk_snap = ApkSnapshot.find_by_id(snap_id)
    apk_snap.scan_status = :scan_success
    apk_snap.last_updated = DateTime.now
    apk_snap.save

  end

end