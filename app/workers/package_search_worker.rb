module PackageSearchWorker

  def perform(app_id)
    aa = AndroidApp.find(app_id)
    app_identifier = aa.app_identifier
    nas = aa.newest_apk_snapshot
    return nil if nas.blank?
    snap_id = nas.id
    find_packages(app_identifier: app_identifier, snap_id: snap_id)
  end

  def find_packages(app_identifier:, snap_id:)

    if Rails.env.production?
      file_name = ApkSnapshot.find(snap_id).apk_file.apk.url
      begin
        s3_file = open(file_name)
      rescue
        ApkSnapshotException.create(name: "couldn't download from s3 bucket")
        raise
      end
      apk = Android::Apk.new(s3_file)
    elsif Rails.env.development?
      file_name = '../../Documents/sample_apps/' + app_identifier + '.apk'
      apk = Android::Apk.new(file_name)
    end

    dex = apk.dex
    packages = dex.classes.map do |cls|
      next if cls.name.blank? || cls.name.downcase.include?(app_identifier.split('.')[1].downcase)
      cls = cls.name.split('/')
      cls.pop
      cls = cls.join('.')
      cls.slice!(0) if cls.slice(0) == 'L'
      cls
    end.compact.uniq

    AndroidSdkService.classify(snap_id: snap_id, packages: packages)

    # puts "#{snap_id} => finished job [#{t.real}]"

    apk_snap = ApkSnapshot.find_by_id(snap_id)
    apk_snap.scan_status = :scan_success
    apk_snap.last_updated = DateTime.now
    apk_snap.save

  end

end