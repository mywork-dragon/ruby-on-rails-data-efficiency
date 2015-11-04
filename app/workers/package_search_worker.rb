module PackageSearchWorker

  def perform(app_id)

    ActiveRecord::Base.logger.level = 1
    aa = AndroidApp.find(app_id)
    app_identifier = aa.app_identifier
    nas = aa.newest_apk_snapshot
    return nil if nas.blank?
    apk_snapshot_id = nas.id
    find_packages(app_identifier: app_identifier, apk_snapshot_id: apk_snapshot_id)

  end

  # def clear_companies

  #   AndroidSdkPackagesApkSnapshot.destroy_all

  #   AndroidSdkPackage.destroy_all

  #   AndroidSdkPackagePrefix.destroy_all

  #   AndroidSdkCompaniesApkSnapshot.destroy_all

  #   AndroidSdkCompaniesAndroidApp.destroy_all

  #   AndroidSdkCompany.destroy_all

  # end


  def find_packages(app_identifier:, apk_snapshot_id:)

    if Rails.env.production?
      file_name = ApkSnapshot.find(apk_snapshot_id).apk_file.apk.url
      apk = Android::Apk.new(open(file_name))
    elsif Rails.env.development?
      file_name = '../../Documents/' + app_identifier + '.apk'
      apk = Android::Apk.new(file_name)
    end

    dex = apk.dex
    clss = dex.classes.map do |cls|
      next if cls.name.blank? || cls.name.downcase.include?(app_identifier.split('.')[1].downcase)
      cls = cls.name.split('/')
      cls.pop
      cls = cls.join('.')
      cls.slice!(0) if cls.slice(0) == 'L'
      cls
    end

    batch = Sidekiq::Batch.new

    if !single_queue?
      batch.on(:complete, PackageSearchServiceWorker, 'apk_snapshot_id' => apk_snapshot_id)
    end

    names = clss.uniq.compact.uniq.map do |package_name|
      SdkCompanyServiceWorker.new.name_from_package(package_name)
    end.uniq

    if Rails.env.development?
      names.each do |package_name|
        SavePackageServiceWorker.new.perform(package_name, apk_snapshot_id)
      end
    else
      batch.jobs do
        names.each do |package_name|
          if single_queue?
          	SavePackageServiceSingleWorker.perform_async(package_name, apk_snapshot_id)
          else
            apk_snap = ApkSnapshot.find_by_id(apk_snapshot_id)
            begin
          	 SavePackageServiceWorker.new.perform(package_name, apk_snapshot_id)
            rescue => e
              apk_snap.scan_status = :scan_failure
              apk_snap.save
            else
              apk_snap.scan_status = :scan_success
              apk_snap.save
            end
          end
        end
      end
    end

  end

  def on_complete(status, options)
    apk_snap = ApkSnapshot.find_by_id(options['apk_snapshot_id'])
    apk_snap.scan_status = :scan_success
    apk_snap.save
  end

end