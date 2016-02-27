class AndroidSdkService

  EX_WORDS = "framework|android|sdk|\\W+"
  LANGS = "java"

  GOOGLE_MAX_RETRIES = 5

  class << self

    def classify(snap_id:, packages:)
      self.new.classify(snap_id: snap_id, packages: packages)
    end

  end

  def initialize(jid: nil, proxy_type: :tor)
    @jid = jid
    @proxy_type = proxy_type
  end

	def classify(snap_id:, packages:)

    puts "#{snap_id}: Package count: #{packages.count}"

    # puts "#{snap_id} => starting scan"

    regex_check = nil
    table_check = nil

		# Save package if it matches a regex
    regexes = SdkRegex.all.select(:regex, :android_sdk_id).where.not(android_sdk_id: nil)
    b = Benchmark.measure {regex_check = miss_match(data: packages, check: :match_regex, regexes: regexes)
		if regex_check[:matched].present?

			c = Benchmark.measure {regex_check[:matched].each do |p| 
				save_package(package: p[:package], android_sdk_id: p[:android_sdk_id], snap_id: snap_id)
			end}

      puts "#{snap_id}: Saving #{regex_check[:matched].length} regexes (#{c.real})"
    end}

    puts "#{snap_id}: Regex time: #{b.real}"

    # puts "#{snap_id} => regex [#{a.real}]" 

		# Save package if it is already in the table
    b = Benchmark.measure {table_check = miss_match(data: regex_check[:missed], check: :match_table)
  	if table_check[:matched].present?
  		c = Benchmark.measure {table_check[:matched].each do |p| 
  			save_package(package: p[:package], android_sdk_id: p[:android_sdk_id], snap_id: snap_id)
  		end}

      puts "#{snap_id}: Saving #{table_check[:matched].length} packages (#{c.real})"
  	end}

    puts "#{snap_id}: Table check time: #{b.real}"

    # puts "#{snap_id} => packages [#{b.real}]"

		# Save package, sdk, and company if it matches a google search

    b = Benchmark.measure {
    google_check = miss_match(data: querify(table_check[:missed]), check: :match_google)
		if google_check[:matched].present?
			google_check[:matched].each do |result|
				meta = result[:metadata]
        g = meta[:github_repo_identifier] || nil
				sdk = save_sdk(name: meta[:name], website: meta[:url], open_source: meta[:open_source], github_repo_identifier: meta[:github_repo_identifier])
				result[:packages].each do |p| 
					save_package(package: p, android_sdk_id: sdk.id, snap_id: snap_id)
				end
			end
		end}

    puts "#{snap_id}: Google time: #{b.real}"

    # puts "#{snap_id} => googling [#{c.real}]"

	end

  private

	def save_sdk(name:, website:, open_source:, github_repo_identifier:)

    android_sdk = AndroidSdk.where(name: name, website: website, open_source: open_source, github_repo_identifier: github_repo_identifier).first

    if android_sdk.nil?
      begin
        return AndroidSdk.create(name: name, website: website, open_source: open_source, github_repo_identifier: github_repo_identifier, kind: :native)
      rescue ActiveRecord::RecordNotUnique => e
        return AndroidSdk.where(name: name).first
      end
    else
      return android_sdk
    end
    
	end

	def save_package(package:, android_sdk_id:, snap_id:)

    sdk_package = SdkPackage.find_by_package(package)
    if sdk_package.nil?
      # save sdk_packages
      sdk_package = begin
        s = SdkPackage.create(package: package)
        s.android_sdk_id = android_sdk_id
        s.save
        s
      rescue ActiveRecord::RecordNotUnique => e
        SdkPackage.where(package: package).first
      end
    end

    spas = SdkPackagesApkSnapshot.where(sdk_package_id: sdk_package.id, apk_snapshot_id: snap_id).first
    if spas.nil?
      # save sdk_packages_apk_snapshots
      begin
        SdkPackagesApkSnapshot.create(sdk_package_id: sdk_package.id, apk_snapshot_id: snap_id)
      rescue ActiveRecord::RecordNotUnique => e
        nil
      end
    end

    asas = AndroidSdksApkSnapshot.where(android_sdk_id: android_sdk_id, apk_snapshot_id: snap_id).first
    if asas.nil?
      # save android_sdks_apk_snapshots
      begin
        AndroidSdksApkSnapshot.create(android_sdk_id: android_sdk_id, apk_snapshot_id: snap_id)
      rescue ActiveRecord::RecordNotUnique => e
        nil
      end
    end
    
  end

	def querify(packages)
    return nil if packages.nil?
		q = Hash.new
		packages.each do |package|
			query = query_from_package(package)
			q[query] = Array.wrap(q[query]) << package
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
    g = google_search(q: "#{query} android sdk", limit: 4)
    puts "g:"
    ap g
    return nil if g.blank?
		g.each do |url|
      # puts "url: #{url}"
			ext = exts(dot: :before).select{|s| url.include?(s) }.first
      # puts "ext: #{ext}"
	    url = remove_sub(url).split(ext).first + ext
      next if remove_sub_first.blank? # fix for this being nil sometimes
      url = remove_sub_first + ext
      # puts "url: #{url}"
	    company = query
      host = URI(url).host
      # puts "host: #{host}"
      # puts "query.downcase: #{query.downcase}"
			return {:url=>url, :name=>company, :open_source=>false, :github_repo_identifier=>nil} if host && host.include?(query.downcase)
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
      q = ['site:github.com', rowner, rname, platform].compact.join(' ')
      g = google_search(q: q, limit: 5)
      next if g.nil?
      g.each do |url|
        if !!(url =~ /#{regex}/i)
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
      #result = nil
      search = nil
      b = Benchmark.measure do
        # result = Proxy.get_nokogiri_with_wait(req: {:host => "www.google.com/search", :protocol => "https"}, params: {'q' => q})

        try = 0

        begin
          # sleep(rand(0.5..1.5)) # be easy on google
          # searcher = GoogleSearcher::Searcher.new(jid: @jid)
          # search = searcher.search(q, proxy_type: :android_classification)

          searcher = BingSearcher::Searcher.new(jid: @jid)
          search = searcher.search(q, proxy_type: @proxy_type)
        rescue => e
          if (try += 1) < GOOGLE_MAX_RETRIES
            puts "Exception: #{e.message}, Retry #{try}"
            retry
          else
            raise
          end
        end
        
      end
      puts "searching (#{q}) [#{b.real}]"
    rescue => e
      ApkSnapshotException.create(name: "search failed (#{q})", status_code: 1)
      raise
    else
	    # result.search('cite').map{ |c| UrlHelper.http_with_url(c.inner_text) if valid_domain?(c.inner_text) }.compact.take(limit) if result
      search.results.map(&:url)
    end
	end

	def valid_domain?(url)
		url.present? && url.exclude?('...') && url != '0' && url.count('-') <= 1
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

	def miss_match(data:, check:, regexes: nil)
    # puts "miss_match, data:"
    # ap data

		m = Hash.new
    return m if data.nil?

    b = Benchmark.measure {data.each do |d|
      if check == :match_regex
        match = send check, d, regexes
      else
        match = send check, d
      end
      if match
        m[:matched] = Array.wrap(m[:matched]) << match
      else
        m[:missed] = Array.wrap(m[:missed]) << d
      end
    end}
    puts "Splitting #{check.to_s}: #{b.real}"
    m
  end

  def match_regex(package, regexes)
    regexes.each do |regex|
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
    sdk_package = nil
  	b = Benchmark.measure{ sdk_package = SdkPackage.find_by_package(package) }
    puts "table matching (#{package}) [#{b.real}]" if b.real >= 1.0
  	if sdk_package
  		return {
  			:package => package,
  			:android_sdk_id => sdk_package.android_sdk_id
  		}
  	end
  	nil
  end

  def match_google(package)
  	results = google_sdk(query: package[0]) || google_github(query: package[0], packages: package[1])
  	if results
  		return {
  			:packages => package[1],
  			:metadata => results
  		}
  	end
  	nil
  end

end