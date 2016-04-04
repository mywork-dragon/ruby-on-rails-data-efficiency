class ApkVersionGetter

  class << self

    def versions(unzipped_apk_path)
      begin
        path_escaped = Shellwords.escape(unzipped_apk_path)
        android_manifest_path = "#{path_escaped}/AndroidManifest.xml"
        file = File.open(android_manifest_path, 'rb').read{ |f| f.read }
        manifest = Android::Manifest.new(file)
        manifest_xml_s = manifest.to_xml
      	manifest_xml = Nokogiri::XML(manifest_xml_s)

  	    version_name = manifest_xml.xpath('//manifest').first['android:versionName']
  	    version_name = version_name.present? ? version_name : nil

        version_code = manifest_xml.xpath('//manifest').first['android:versionCode']
        version_code = version_code.present? ? version_code.to_i : nil

        {version_name: version_name, version_code: version_code}
      rescue => e
        {}
      end
    end

  end
  
end