class PackageVersion

  class << self

    def get(app_identifier:)

    	file_name = PackageSearchServiceWorker.new.apk_file_name(app_identifier: app_identifier)

    	apk = Android::Apk.new(file_name)

    	manifest_xml = Nokogiri::XML(apk.manifest.to_xml)

	    version = manifest_xml.xpath('//manifest').first['android:versionName']

	    version = version.present? ? version : nil

	    version

    end

  end
  
end