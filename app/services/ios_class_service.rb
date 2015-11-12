class IosClassService

	class << self

    def bundle_prefixes
      %w(com co net org edu io ui gov cn jp me forward pay common de se oauth main java pl nl rx uk eu fr)
    end

    def classify(snap_id)
      ActiveRecord::Base.logger.level = 1

      classdump = IpaSnapshot.find(snap_id).class_dump
      if Rails.env.production?

        url = classdump.class_dump.url
        contents = open(url).read
      elsif Rails.env.development?

        snap = IpaSnapshot.find(snap_id)
        filename = `echo $HOME`.chomp + "/decrypted_ios_apps/#{snap.ios_app_id}"
        ext = classdump.method == 'classdump' ? ".classdump.txt" : ".txt"
        filename = filename + ext

        contents = File.open(filename) {|f| f.read}.chomp
      end

      if classdump.method == 'classdump'
        classify_classdump(snap_id, contents)
      else classdump.method == 'strings'
      	classify_strings(snap_id, contents)
      end
    end

    def classify_classdump(snap_id, contents)

      classes = contents.scan(/@interface (.*?) :/m).map{ |k,v| k }.uniq

      search_classnames(classes, snap_id)
    end

    def classify_strings(snap_id, contents)

    	ActiveRecord::Base.logger.level = 1

      classes = contents.scan(/T@"<?([_\p{Alnum}]+)>?"(?:,.)*_?\p{Alpha}*/).flatten.uniq.compact
      bundles = contents.scan(/^(?:#{bundle_prefixes.join('|')})\.(.*)/).flatten.uniq
      fw_folders = contents.scan(/^Folder:(.+)\n/).flatten.uniq

      
      search_bundles(bundles, snap_id)
      search_fw_folders(fw_folders, snap_id)
      search_classnames(classes, snap_id)
    end

    def search_classnames(names, snap_id)
      result = []
      names.each do |name|

        found = search(name) || code_search(name)

        next if found.nil?

        begin
          # IosSdksIpaSnapshot.create(ios_sdk: found.id, ipa_snapshot_id: snap_id)
          result.push(found.name)
        rescue
          nil
        end
      end
      result.uniq
    end

    def search_bundles(bundles, snap_id)
      nil
      # bundles.each do |bundle|

      # end
    end

    def run_broken(arr = nil)

      arr = CocoapodException.select(:cocoapod_id).map{|x| x.cocoapod_id} if arr.nil?

      arr.uniq.each do |cocoapod_id|
        CocoapodDownloadWorker.perform_async(cocoapod_id)
      end
    end

    def search_fw_folders(folders, snap_id)
      nil
    end

    def search(q)
      s = %w(sdk -ios-sdk -ios -sdk).map{|p| q+p } << q
      c = IosSdk.find_by_name(s)
      c if c.present?
    end

    def code_search(name)

      c = CocoapodSourceData.where(name: name)
      ios_sdks = c.map do |csd|
        pod = csd.cocoapod
        if !pod.nil?
          pod.ios_sdk
        end
      end.compact.uniq

      puts "found #{ios_sdks.length} matches for #{name}"
      ios_sdks.length <= 1 ? ios_sdks.first : handle_collisions(ios_sdks)
    end

    def get_downloads_for_sdk(sdk)
      most_recent = sdk.cocoapod_metrics.select {|metrics| metrics.success}.sort_by {|x| x.updated_at}.last
      most_recent ? most_recent.stats_download_total : 0
    end

    def handle_collisions(sdks, req = 0.8)

      puts "Collision between #{sdks.map {|x| x.name}.join(',')}"
      # use total downloads as proxy
      downloads = sdks.map {|sdk| get_downloads_for_sdk(sdk)}
      total = downloads.reduce(0) {|x, y| x + y}

      byebug

      highest = downloads.max
      sdks[downloads.find_index(highest)] if highest > req * total
    end

	end

end