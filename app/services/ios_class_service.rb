class IosClassService

	class << self

    def classify(snap_id)
      ActiveRecord::Base.logger.level = 1

      class_dump = IpaSnapshot.find(snap_id).class_dump

      if class_dump.method == 'classdump'
        classify_classdump(snap_id)
      else class_dump.method == 'strings'
      	classify_strings(snap_id)
      end
    end

    def classify_strings(snap_id)

    	ActiveRecord::Base.logger.level = 1

    	url = IpaSnapshot.find(snap_id).class_dump.class_dump.url
    	lines = open(url).read

    	# Look for delegates first
    	delegates =	    	
    end

    def extract_by_regex(contents, regex)
    	matches = lines.map {|line| regex.match(line)}.compact
    	output = matches.map {|x| yield(x)}.uniq
    end

    def classify_classdump(snap_id)

      ActiveRecord::Base.logger.level = 1

      snap = IpaSnapshot.find(snap_id)

      class_names(snap.id).each do |q|

        r = code_search(q) || search(q)

        next if r.nil? || q.nil?

        begin

          i = IosSdk.create(name: r.name, website: r.link, cocoapod: r)
          os = r.link.include? 'github'

          if !os
            favicon = WWW::Favicon.new
            favicon_url = favicon.find(url)
            i.favicon = favicon_url
          end

          i.open_source = os
          i.save

        rescue
          i = IosSdk.find_by_cocoapod_id(r.id)
        end

        begin
          IosSdksIpaSnapshot.create(ios_sdk: i, ipa_snapshot: snap)
        rescue
          nil
        end

      end
      nil
    end

    def class_names(snap_id)
      url = IpaSnapshot.find(snap_id).class_dump.class_dump.url
      d = open(url).read
      d.scan(/@interface (.*?) :/m).map{ |k,v| k }.uniq
    end

    def search(q)
      s = %w(sdk -ios-sdk -ios -sdk).map{|p| q+p } << q
      c = Cocoapod.find_by_name(s)
      c if c.present?
    end

    def code_search(q)
      c = CocoapodSourceData.find_by_name(q)
      c.cocoapod if c.present?
    end

	end

end