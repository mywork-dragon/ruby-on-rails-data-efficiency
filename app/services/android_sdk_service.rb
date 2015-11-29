class AndroidSdkService

	class << self

		def classify(snap_id:, packages:)

			# packages.each{|x| puts x }.count

			# return nil

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


			# FOR THE GITHUB SEARCH, SAVE THE REPO AS THE SDK AND THE AUTHOR AS THE COMPANY

			# Save package, sdk, and company if it matches a google search
			google_check = miss_match(data: querify(table_check[:missed]), check: :match_google)
			# ap google_check[:matched]
			if google_check[:matched].present?
				google_check[:matched].each do |result|
					# sdk_company = save_company(name: result[:name], url: result[:url])
					meta = result[:metadata]
					sdk = save_sdk(name: meta[:name], website: meta[:url], open_source: meta[:open_source])
					result[:packages].each do |p| 
						save_package(package: p, android_sdk_id: sdk.id, snap_id: snap_id)
					end
				end
			end

			return google_check

			# google_check[:missed].each do |res|
			# 	puts res
			# end

		end

		def save_sdk(name:, website:, open_source:, snap_id:)
			begin
    		AndroidSdk.create(name: name, website: website, open_source: open_source)
    	rescue
    		AndroidSdk.where(name: name).first
    	end
		end

		def save_package(package:, android_sdk_id:, snap_id:)
    	sdk_package = begin
    		SdkPackage.create(package: package)
    	rescue
    		SdkPackage.find_by_package(package)
    	end
    	if sdk_package.android_sdk_id != android_sdk_id
	    	sdk_package.android_sdk_id = android_sdk_id
	    	sdk_package.save
	    end
    	SdkPackagesApkSnapshot.create(sdk_package_id: sdk_package.id, apk_snapshot_id: snap_id)
    	# AndroidSdksApkSnapshot.create(android_sdk_id: android_sdk.id, apk_snapshot_id: snap_id)
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

		def google_sdk(query:, platform: :android)
			google_search(q: "#{query} #{platform} sdk", limit: 4).each do |url|
				ext = exts(dot: :before).select{|s| url.include?(s) }.first
		    url = remove_sub(url).split(ext).first + ext
		    company = query
				return {:url=>url, :name=>company, :open_source=>false} if url.include?(query.downcase)
			end
			nil
		end

		# Get the url and company name of an sdk from github if it is valid


		# ADD JASON'S STUFF TO GOOGLE GITHUB

		def google_github(query:, platform: :android)
			google_search(q: "#{query} #{platform} site:github.com").each do |url|
				if !!(url =~ /https:\/\/github.com\/[a-z]*\/#{query}[^\/]*/i)
					company = camel_split(url[/\/([^\/]+)(?=\/[^\/]+\/?\Z)/i,1])
					return {:url=>url, :name=>company, :open_source=>true}
				end
			end
			nil
		end

		def google_search(q:, limit: 10)
		  result = Proxy.get_nokogiri(req: {:host => "www.google.com/search", :protocol => "https"}, params: {'q' => q})
		  result.search('cite').map{ |c| UrlHelper.http_with_url(c.inner_text) if valid_domain?(c.inner_text) }.compact.take(limit)
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
    	results = google_sdk(query: package[0]) || google_github(query: package[0])
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