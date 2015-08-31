class PackageSearchService

  class << self

    def find_packages(app_identifier:, apk_snapshot_id:, file_name:)

      # Change path to work with s3 bucket

      # file_path = '../../Desktop/' + app_identifier + '.apk'

      apk = Android::Apk.new(file_name)

      manifest_xml = Nokogiri::XML(apk.manifest.to_xml)

      manifest_xml.xpath('//activity','//receiver','//action','//meta-data').each do |tag|

        package_name = %w(android:name :).map{|t| tag[t] }.compact.first.to_s

        name = app_identifier.split('.')[1]

        is_android = %w(com.android. android.).any?{|n| " #{package_name}".include? " #{n}" }

        if package_name.present? && package_name.exclude?(name) && !is_android

          save_package(package_name: package_name, apk_snapshot_id: apk_snapshot_id)

        end

      end

      version = manifest_xml.xpath('//manifest').first['android:versionName']

      # Change path to work with s3 bucket

      # file_name = '../../Desktop/' + app_identifier + '_' + version + '.xml'

      # File.open(file_name, 'wb') { |file| file.write(manifest_xml) }

      version = version.present? ? version : nil

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
  
end