class AndroidSdkService

  EX_WORDS = "framework|android|sdk|\\W+"
  LANGS = "java"


	class << self

		def classify(snap_id:, packages:)

			# Save package if it matches a regex
			regex_check = miss_match(data: packages, check: :match_regex)
			if regex_check[:matched].present?
				regex_check[:matched].each do |p| 
					save_package(package: p[:package], android_sdk_id: p[:android_sdk_id], snap_id: snap_id)
				end
			end


			# Save package if it is already in the table
			table_check = miss_match(data: regex_check[:missed], check: :match_table)
			if table_check[:matched].present?
				table_check[:matched].each do |p| 
					save_package(package: p[:package], android_sdk_id: p[:android_sdk_id], snap_id: snap_id)
				end
			end

			# Save package, sdk, and company if it matches a google search
			google_check = miss_match(data: querify(table_check[:missed]), check: :match_google)
			if google_check[:matched].present?
				google_check[:matched].each do |result|
					meta = result[:metadata]
					sdk = save_sdk(name: meta[:name], website: meta[:url], open_source: meta[:open_source])
					result[:packages].each do |p| 
						save_package(package: p, android_sdk_id: sdk.id, snap_id: snap_id)
					end
				end
			end

			return google_check

		end


    private

		def save_sdk(name:, website:, open_source:)
			begin
    		AndroidSdk.create(name: name, website: website, open_source: open_source)
    	rescue
    		AndroidSdk.where(name: name).first
    	end
		end

		def save_package(package:, android_sdk_id:, snap_id:)

      # save sdk_packages
    	sdk_package = begin
    		SdkPackage.create(package: package)
    	rescue
    		SdkPackage.find_by_package(package)
    	end
    	if sdk_package.android_sdk_id != android_sdk_id
	    	sdk_package.android_sdk_id = android_sdk_id
	    	sdk_package.save
	    end

      # save sdk_packages_apk_snapshots
      begin
        SdkPackagesApkSnapshot.create(sdk_package_id: sdk_package.id, apk_snapshot_id: snap_id)
      rescue
        nil
      end

      # save android_sdks_apk_snapshots
      begin
        AndroidSdksApkSnapshot.create(android_sdk_id: android_sdk_id, apk_snapshot_id: snap_id)
      rescue
        nil
      end
    end

		def querify(packages)
			q = Hash.new
			packages.each do |package|
				query = query_from_package(package)
				q[query] = build q[query], package
			end
			q
		end

		# Extract company name from a package (ex. "com.facebook.activity" => "facebook")

		def query_from_package(package_name)
	    package = strip_prefix(package_name)
	    return nil if package.blank?
	    package = package.capitalize if package == package.upcase && package.count('.').zero?
	    first_word = package.split('.').first
	    name = camel_split(first_word)
	    return nil if name.nil? || name.length <= 1
	    name
		end

		# Get the url of an sdk if it is valid

		def google_sdk(query:)
      return nil if query.blank?
			google_search(q: "#{query} android sdk", limit: 4).each do |url|
				ext = exts(dot: :before).select{|s| url.include?(s) }.first
		    url = remove_sub(url).split(ext).first + ext
		    company = query
				return {:url=>url, :name=>company, :open_source=>false} if url.include?(query.downcase)
			end
			nil
		end

		# Get the url and company name of an sdk from github if it is valid


    def google_github(query:, packages:, platform: :android)

      r = find_suffixes(packages)

      g = "https:\\/\\/github.com\\/[^\\/]*"
      match_repo = g+"\\/[^\\/]*#{query}[^\\/]*\\z"

      prefix = [[nil,query,match_repo]]
      suffixes = r.map do |x|
        reg = g+"#{query}*\\/[^\\/]*#{x}*[^\\/]*\\z"
        [query,x,reg]
      end

      searches = prefix + suffixes

      searches.each do |rowner, rname, regex|
        q = [rowner, rname, platform, 'site:github.com'].compact.join(' ')
        puts q.green
        google_search(q: q, limit: 5).each do |url|
          if !!(url =~ /#{regex}/i)
            puts url.purple
            matched = github_data_match(url, rname, rowner)
            return matched if matched.present?
          end
        end
      end

      nil
    end

    def github_data_match(url, rname, rowner)
      rd = GithubService.get_repo_data(url)
      if rd['message'] != 'Not Found' && !!(rd['language'] =~ /#{LANGS}/i)
        rname_match = close_enough?(str1: rname, str2: rd['name'], ex: EX_WORDS)
        rowner_match = close_enough?(str1: rowner, str2: rd['owner']['login'], ex: EX_WORDS)

        if rname_match || (rname_match && rowner_match)
          result = {
            url: url,
            name: cap_first_letter(rd['name']),
            open_source: true,
            github_repo_identifier: rd['id']
          }

          return result
        end
      end
      nil
    end


    def close_enough?(str1:, str2:, threshold: 0.9, ex: nil)
      return false if [str1,str2].any?(&:nil?)
      str1, str2 = [str1, str2].map{|x| x.gsub(/#{ex}/i,'') }
      dice_similarity = FuzzyMatch::Score::PureRuby.new(str1, str2).dices_coefficient_similar
      dice_similarity >= threshold
    end

    def find_suffixes(packages)
      packages.map do |package|
        s = strip_prefix(package).split('.').compact.select{|x| x.length > 1 }
        s.shift
        s
      end.flatten.uniq
    end

		def google_search(q:, limit: 10)
      begin
		    result = Proxy.get_nokogiri(req: {:host => "www.google.com/search", :protocol => "https"}, params: {'q' => q})
      rescue => e
        ApkSnapshotException.create(name: "search failed (#{q})", status_code: 1)
        raise
      else
		    result.search('cite').map{ |c| UrlHelper.http_with_url(c.inner_text) if valid_domain?(c.inner_text) }.compact.take(limit)
      end
		end

		def valid_domain?(url)
			url.exclude?('...') && url != '0' && url.count('-') <= 1
		end

		def remove_sub(url)
			sub_exts = File.open('sdk_configs/bad_url_prefixes.txt').read.gsub("\n","|")
			url.gsub(/(#{sub_exts})\./,'')
		end

		def exts(dot: nil, subs: false)
			path = subs == true ? 'bad_package_prefixes' : 'exts'		
			ext_file = File.open("sdk_configs/#{path}.txt")
			ext_arr = ext_file.read.split(/\n/)
			ext_arr.map{|e| dot == :before ? ".#{e}" : (dot == :after ? "#{e}." : e)}
		end

		def strip_prefix(package)
			package_name = strip(package, exts)
			strip(package_name, exts(subs: true))
		end

		def strip(package, extentions)
	    package_arr = package.split(/\./)
	    prefix = package_arr.first
	    package_arr.shift if extentions.include?(prefix) || prefix.blank?
	    package_arr.join('.')
		end

		def camel_split(str)
			str.split(/(?=[A-Z])/).map(&:capitalize).join(' ').strip
		end

    def cap_first_letter(str)
      str.slice(0,1).capitalize + str.slice(1..-1)
    end

		def miss_match(data:, check:)
			m = Hash.new
      data.each do |d|
        match = send check, d
        if match
        	m[:matched] = build m[:matched], match
        else
        	m[:missed] = build m[:missed], d
        end
      end
      m
    end

    def match_regex(package)
      SdkRegex.all.each do |regex|
        if !!(package =~ /#{regex.regex}/i)
        	return { 
        		:package => package, 
        		:android_sdk_id => regex.android_sdk_id 
        	}
        end
      end
      nil
    end

    def match_table(package)
    	sdk_package = SdkPackage.find_by_package(package)
    	if sdk_package
    		return {
    			:package => package,
    			:android_sdk_id => sdk_package.android_sdk_id
    		}
    	end
    	nil
    end

    def match_google(package)
    	puts "googling #{package[0]}".green
    	results = google_sdk(query: package[0]) || google_github(query: package[0], packages: package[1])
    	if results
    		return {
    			:packages => package[1],
    			:metadata => results
    		}
    	end
    	nil
    end

    def build(key, value)
    	key.nil? ? [value] : key << value
    end

	end

end