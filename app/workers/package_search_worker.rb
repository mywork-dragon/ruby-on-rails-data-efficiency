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
      apk = Android::Apk.new(open(file_name))
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

    # apk_snap = ApkSnapshot.find_by_id(snap_id)

    # begin
    #   as = AndroidSdkService.classify(snap_id: snap_id, packages: packages)
    # rescue => e
    #   apk_snap.scan_status = :scan_failure
    # else
    #   apk_snap.scan_status = :scan_success
    # end

    # apk_snap.save



    AndroidSdkService.classify(snap_id: snap_id, packages: packages)


    # batch = Sidekiq::Batch.new

    # if single_queue?
    #   batch.on(:complete, PackageSearchServiceSingleWorker, 'snap_id' => snap_id)
    # else
    #   batch.on(:complete, PackageSearchServiceWorker, 'snap_id' => snap_id)
    # end

    # names = clss.uniq.compact.uniq.map do |package_name|
    #   SdkCompanyServiceWorker.new.name_from_package(package_name)
    # end.uniq

    # if Rails.env.development?
    #   names.each do |package_name|
    #     SavePackageServiceWorker.new.perform(snap_id: snap_id, packages: packages)
    #   end
    # else
    #   batch.jobs do
    #     names.each do |package_name|
    #       if single_queue?
    #       	SavePackageServiceSingleWorker.perform_async(package_name, snap_id)
    #       else
    #         apk_snap = ApkSnapshot.find_by_id(snap_id)
    #         begin
    #       	 SavePackageServiceWorker.new.perform(package_name, snap_id)
    #         rescue => e
    #           apk_snap.scan_status = :scan_failure
    #           apk_snap.save
    #         else
    #           apk_snap.scan_status = :scan_success
    #           apk_snap.save
    #         end
    #       end
    #     end
    #   end
    # end

  end

  # def on_complete(status, options)
  #   apk_snap = ApkSnapshot.find_by_id(options['snap_id'])
  #   apk_snap.scan_status = :scan_success
  #   apk_snap.save
  # end

end