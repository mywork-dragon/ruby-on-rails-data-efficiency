class PackageSearchServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => 2, queue: :sdk_single

  def perform(app_id)

    aa = AndroidApp.find(app_id)

    app_identifier = aa.app_identifier

    nas = aa.newest_apk_snapshot

    return nil if nas.blank?

    apk_snapshot_id = nas.id

    find_packages(app_identifier: app_identifier, apk_snapshot_id: apk_snapshot_id)

  end

  # def apk_file_name(app_identifier: app_identifier, apk_snapshot_id: apk_snapshot_id)

  #   if Rails.env.production?

  #     file_name = ApkSnapshot.find(apk_snapshot_id).apk_file.apk.url

  #   elsif Rails.env.development?
      
  #     file_name = '../../Documents/' + app_identifier + '.apk'
    
  #   end
    
  #   file_name
  
  # end

  def find_packages(app_identifier:, apk_snapshot_id:)

    # file_name = apk_file_name(app_identifier: app_identifier, apk_snapshot_id: apk_snapshot_id)

    # apk = Android::Apk.new(file_name)

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

    clss.uniq.compact.uniq.each do |package_name|

      save_package(package_name: package_name, apk_snapshot_id: apk_snapshot_id)

    end

  end

  def save_package(package_name:, apk_snapshot_id:)

    name = SdkCompanyServiceWorker.new.name_from_package(package_name)

    if name.present?

      prefix = AndroidSdkPackagePrefix.find_or_create_by(prefix: name)

      company_id = prefix.android_sdk_company_id.nil? ? SdkCompanyServiceWorker.new.create_company_from_name(name) : prefix.android_sdk_company_id

      if company_id.present?

        aa = ApkSnapshot.find(apk_snapshot_id).android_app

        AndroidSdkCompaniesAndroidApp.find_or_create_by(android_sdk_company_id: company_id, android_app_id: aa.id)

      end

      package = AndroidSdkPackage.create_with(android_sdk_package_prefix: prefix).find_or_create_by(package_name: package_name)

      AndroidSdkPackagesApkSnapshot.find_or_create_by(android_sdk_package_id: package.id, apk_snapshot_id: apk_snapshot_id)

    end

  end
  
end