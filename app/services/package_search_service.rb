class PackageSearchService

  class << self

    def search(app_identifier, apk_snap_id, file_name)
      manifest, unpack_time = extract_manifest(app_identifier, file_name)
      name = get_name(app_identifier)
      find(manifest, name, apk_snap_id, unpack_time)

      unpack_time
    end

    def extract_manifest(app_identifier, file_name)

      print "Searching for sdks in #{app_identifier}... " if Rails.env.development?
      
      start_time = Time.now()

      apk = Android::Apk.new(file_name)
      manifest = apk.manifest

      print 'success' if Rails.env.development?

      end_time = Time.now()
      unpack_time = (end_time - start_time).to_s
      
      return manifest, unpack_time

    end

    def find(manifest, name, apk_snap_id, unpack_time)
      manifest_xml = Nokogiri::XML(manifest.to_xml)
      find = ["activity", "action", "meta-data"]
      found = []
      i = 0
      for f in find
        tags = manifest_xml.xpath("//#{f}")
        for tag in tags
          app_identifier = tag["android:name"] unless tag["android:name"].nil?
          app_identifier = tag[":"] unless tag[":"].nil?
          unless app_identifier.nil?
            unless app_identifier.include? name
              save_package(app_identifier, find.index(f), apk_snap_id)
              i += 1
            end
          end
        end
      end
      # li " ( time : #{unpack_time} sec, packages_found : #{i} )" if Rails.env.development?

      # app_id = AndroidApp.find_by_app_identifier(app_identifier).id

      app_id = ApkSnapshot.find(apk_snap_id).android_app_id
      company_ids = SdkCompanyServiceWorker.new.find_company(app_id)

      company_ids.each do |id|
         SdkCompanyServiceWorker.new.google_company(id)
      end

    end

    def save_package(app_identifier, tag, apk_snap_id)
      AndroidPackage.create(package_name: app_identifier, android_package_tag: tag, apk_snapshot_id: apk_snap_id, identified: false, not_useful: false)
    end

    def get_name(app_identifier)
      app_identifier.split('.')[1]
    end

  end
  
end