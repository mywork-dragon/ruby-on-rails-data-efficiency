class IosClassService

	class << self

    def bundle_prefixes
      %w(com co net org edu io ui gov cn jp me forward pay common de se oauth main java pl nl rx uk eu fr)
    end

    def classify(snap_id)
      ActiveRecord::Base.logger.level = 1

      classdump = ClassDump.where(ipa_snapshot_id: snap_id, dump_success: true).last

      return if classdump.nil?

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

      puts "Classifying classdump".red
      classes = contents.scan(/@interface (.*?) :/m).map{ |k,v| k }.uniq

      search_classnames(classes, snap_id)
    end

    # Entry point to integrate with @osman
    def classify_strings(snap_id, contents)

      puts "Classifying strings".blue
      # sdks_from_strings_googled(contents: contents, search_fw_folders: true)
     # store_sdks_from_strings_googled(snap_id: snap_id, contents: contents)
     sdks_from_strings(contents: contents)

    end

    # Get classes from strings
    def classes_from_strings(contents)
      contents.scan(/T@"<?([_\p{Alnum}]+)>?"(?:,.)*_?\p{Alpha}*/).flatten.uniq.compact
    end

    # Get bundles from strings
    def bundles_from_strings(contents)
      contents.scan(/^(?:#{bundle_prefixes.join('|')})\..*/)
    end

    # Get FW folders from strings
    def fw_folders_from_strings(contents)
      contents.scan(/^Folder:(.+)\n/).flatten.uniq
    end

    def sdks_from_strings(contents:, search_classes: false, search_bundles: true, search_fw_folders: false)

      sdks = []

      if search_bundles
        bundles = bundles_from_strings(contents)
        sdks += SdkService.find_from_packages(packages: bundles, platform: :ios, read_only: true) # TODO: remove read only flag
        puts "SDKs via bundles"
        ap sdks
      end

      if search_classes
        classes = classes_from_strings(contents)
        # TODO: write an SdkService.find_from_classes
      end

      if search_fw_folders
        fw_folders = fw_folders_from_strings(contents)
        # TODO: write an SdkService.find_from_fw_folders
      end

      sdks
    end

    # Never string search classes for now (because it's too many)
    def sdks_from_strings_googled(contents:, search_classes: false, search_bundles: true, search_fw_folders: false)
      queries = []

      if search_classes
        classes = classes_from_strings(contents)
        queries += classes # query the classes without added filtering 
      end

      if search_bundles
        bundles = bundles_from_strings(contents)
        queries += bundles.map{ |bundle| SdkService.query_from_package(bundle)} # pull out the package names to query
      end

      if search_fw_folders
        fw_folders = fw_folders_from_strings(contents)
        queries += fw_folders
      end

      if true # debug only
        puts "Classes:".green
        ap classes
        puts ""

        puts "Bundles:".green
        ap bundles
        puts ""

        puts "FW Folders:".green
        ap fw_folders
        puts ""
      end

      queries = queries.compact.uniq{ |x| x.downcase }

      puts "Queries".purple
      ap queries

      SdkService.find_from_queries(queries: queries, platform: :ios)
    end

    def store_sdks_from_strings_googled(snap_id: snap_id, contents: contents)
      sdks_h = sdks_from_strings_googled(contents: contents)

      sdks_h.each do |sdk|

        sdk_kind = sdk[:kind]

        if sdk_kind == :company
        	begin
            url = sdk[:url]
            company = sdk[:company]

          	ios_sdk = IosSdk.create!(name: company, website: url, open_source: false)
            ios_sdk.favicon = WWW::Favicon.new.find(url)
            ios_sdk.save!
        	rescue ActiveRecord::RecordNotUnique => e
        		ios_sdk = IosSdk.find_by_name(company)
        	end
        elsif sdk_kind == :open_source
        	begin
            repo_id = sdk[:repo_id]
          	ios_sdk = IosSdk.create!(name: sdk[:repo_name], website: sdk[:url], favicon: sdk[:favicon], open_source: true, summary: sdk[:repo_description], github_repo_identifier: repo_id)
        	rescue ActiveRecord::RecordNotUnique => e
            ios_sdk = IosSdk.find_by_github_repo_identifier(repo_id)
        	end
        end

        IosSdksIpaSnapshot.create!(ios_sdk_id: ios_sdk.id, ipa_snapshot_id: snap_id)
      end
    end

    def sdks_from_strings_cocoapods(contents)
      fw_folders.each do |fw_folder|
        ios_sdk = IosSdk.where('lower(name) = ?', fw_folder.downcase).first
      end
    end

    def store_sdks_from_strings_cocoapods(contents)

      
    end


    # Entry point forC
    def sdks_from_strings_file(filename)
      contents = File.open(filename) { |f| f.read }.chomp
      sdks_from_strings_googled(contents: contents, search_classes: false, search_bundles: true, search_fw_folders: true)
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

    # For testing, entry point to classify string
    # @author Jason Lew
    def search_bundles_from_file(filename)
      contents = File.open(filename) { |f| f.read }.chomp

      bundles = contents.scan(/^(?:#{bundle_prefixes.join('|')})\.(.*)/).flatten.uniq
      ap bundles

      search_bundles(bundles, nil)
    end

    # Create entry in join table for every one that it finds
    def search_bundles(bundles, snap_id)
      SdkService.find_from_packages(packages: bundles, platform: :ios)
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
      res = most_recent ? most_recent.stats_download_total || 0 : 0
    end

    def handle_collisions(sdks, req = 0.8)

      puts "Collision between #{sdks.map {|x| x.name}.join(',')}"
      # use total downloads as proxy
      downloads = sdks.map {|sdk| get_downloads_for_sdk(sdk)}
      total = downloads.reduce(0) {|x, y| x + y}

      highest = downloads.max
      sdks[downloads.find_index(highest)] if highest > req * total

      # TODO: consider hard links
    end

	end

end