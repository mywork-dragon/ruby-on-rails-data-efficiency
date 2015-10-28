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

      search_classnames(classes, snap_id)
      search_bundles(bundles, snap_id)
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

    def search_bundles(bundles, snap_id)
      nil
      # bundles.each do |bundle|

      # end
    end

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