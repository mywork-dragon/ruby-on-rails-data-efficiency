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

    	# ActiveRecord::Base.logger.level = 1

     #  classes = contents.scan(/T@"<?([_\p{Alnum}]+)>?"(?:,.)*_?\p{Alpha}*/).flatten.uniq.compact
     #  bundles = contents.scan(/^(?:#{bundle_prefixes.join('|')})\.(.*)/).flatten.uniq
     #  fw_folders = contents.scan(/^Folder:(.+)\n/).flatten.uniq

     #  search_classnames(classes, snap_id)
     #  search_bundles(bundles, snap_id)
     #  search_fw_folders(fw_folders, snap_id)

     store_sdks_from_strings_googled(contents)


    end

    # Get classes from strings
    def classes_from_strings(contents)
      contents.scan(/T@"<?([_\p{Alnum}]+)>?"(?:,.)*_?\p{Alpha}*/).flatten.uniq.compact
    end

    # Get bundles from strings
    def bundles_from_strings(contents)
      contents.scan(/^(?:#{bundle_prefixes.join('|')})\.(.*)/).flatten.uniq
    end

    # Get FW folders from strings
    def fw_folders_from_strings(contents)
      contents.scan(/^Folder:(.+)\n/).flatten.uniq
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

    def store_sdks_from_strings_googled(contents)
      sdks_h = store_sdks_from_strings_googled(contents: contents)

      sdhks_h.each do |sdk|

        if sdk[:kind] == :company

        begin
          ios_sdk = IosSdk.create(name: sdk.name, website: sdk.url, cocoapod: found)
        rescue ActiveRecord::RecordNotUnique => e
        end

      end
    end

    def sdks_from_strings_cocoapods(contents)
      fw_folders.each do |fw_folder|
        ios_sdk = IosSdk.where('lower(name) = ?', fw_folder.downcase).first
      end
    end

    def store_sdks_from_strings_cocoapods(contents)

      
    end


    # Entry point for
    def sdks_from_strings_file(filename)
      contents = File.open(filename) { |f| f.read }.chomp
      sdks_from_strings_googled(contents: contents, search_classes: false, search_bundles: true, search_fw_folders: true)
    end

    def search_classnames(names, snap_id)
      names.each do |name|

        found = code_search(name) || search(name)

        next if found.nil?

        begin
          i = IosSdk.create(name: found.name, website: found.link, cocoapod: found)
        rescue
          i = IosSdk.find_by_cocoapod_id(found.id)
        end

        begin
          IosSdksIpaSnapshot.create(ios_sdk: i, ipa_snapshot_id: snap_id)
        rescue
          nil
        end
      end
      nil
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
      SdkService.find(packages: bundles, platform: :ios)
    end

    def search_fw_folders(folders, snap_id)
      nil
    end

    # 
    def search(q)
      s = %w(sdk -ios-sdk -ios -sdk).map{|p| q+p } << q
      c = Cocoapod.find_by_name(s)
      c if c.present?
    end

    def code_search(q)
      c = CocoapodSourceData.where(name: q)
      c[0].cocoapod if c.length == 0 # ignore matches that don't uniquely identify
    end

	end

end