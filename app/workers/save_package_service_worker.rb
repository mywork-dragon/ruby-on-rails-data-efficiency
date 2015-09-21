class SavePackageServiceWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sdk_single

  def perform(package_name, apk_snapshot_id)

    save_package(package_name: package_name, apk_snapshot_id: apk_snapshot_id)

  end

  def save_package(package_name:, apk_snapshot_id:)

    name = SdkCompanyServiceWorker.new.name_from_package(package_name)

    if name.present?

      prefix = AndroidSdkPackagePrefix.find_or_create_by(prefix: name)

      company_id = prefix.android_sdk_company_id.nil? ? SdkCompanyServiceWorker.new.create_company_from_name(name) : prefix.android_sdk_company_id

      if company_id.present?

        aa = ApkSnapshot.find(apk_snapshot_id).android_app

        begin
          
          AndroidSdkCompaniesApkSnapshot.find_or_create_by(android_sdk_company_id: company_id, apk_snapshot_id: apk_snapshot_id)

          AndroidSdkCompaniesAndroidApp.find_or_create_by(android_sdk_company_id: company_id, android_app_id: aa.id)

        rescue
          
          nil

        end
        

      end

      package = AndroidSdkPackage.create_with(android_sdk_package_prefix: prefix).find_or_create_by(package_name: package_name)

      AndroidSdkPackagesApkSnapshot.find_or_create_by(android_sdk_package_id: package.id, apk_snapshot_id: apk_snapshot_id)

    end

  end
  
end