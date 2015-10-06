class PackageVersion

  class << self

    def get(file_name:)

    	apk = Android::Apk.new(file_name)

    	manifest_xml = Nokogiri::XML(apk.manifest.to_xml)

	    version = manifest_xml.xpath('//manifest').first['android:versionName']

	    version = version.present? ? version : nil

	    version

    end

  end
  
end