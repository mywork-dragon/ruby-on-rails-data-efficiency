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

    
    if Rails.env.production?
      apk_snap = ApkSnapshot.find(snap_id)
      file_name = apk_snap.apk_file.apk.url
      file_size = apk_snap.apk_file.apk.size
      b = Benchmark.measure { 
      s3_file = open(file_name)}
      c = Benchmark.measure {
      apk = Android::Apk.new(s3_file)}
    elsif Rails.env.development?
      file_name = '../../Documents/sample_apps/' + app_identifier + '.apk'
      apk = Android::Apk.new(file_name)
    end

    puts "#{snap_id}: Download time: #{b.real}"
    puts "#{snap_id}: Download rate: #{(file_size.to_f/1000000.0)/b.real} mb/s"
    puts "#{snap_id}: Unpack time: #{c.real}"

    # puts "#{snap_id} => downloaded [#{a.real}]"

    dex = apk.dex
    packages = dex.classes.map do |cls|
      next if cls.name.blank? || cls.name.downcase.include?(app_identifier.split('.')[1].downcase)
      cls = cls.name.split('/')
      cls.pop
      cls = cls.join('.')
      cls.slice!(0) if cls.slice(0) == 'L'
      cls
    end.compact.uniq


    b = Benchmark.measure {AndroidSdkService.classify(snap_id: snap_id, packages: packages)}

    puts "#{snap_id}: Classify Time: #{b.real}"

    # apk_snap = ApkSnapshot.find_by_id(snap_id)
    apk_snap.scan_status = :scan_success
    apk_snap.last_updated = DateTime.now
    apk_snap.save

  end

end