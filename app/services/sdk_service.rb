class SdkService

    QUERY_MINIMUM_LENGTH = 4
    DICE_SIMILARITY_THRESHOLD = 0.9
    ANDROID_CLASS_CLASSIFIER = AndroidClassClassifier.new('s3://ms-classification-models/latest.json.gz')

    class << self

        def platform_map(platform:)
            if platform == :ios
                {
                    app_table: IosApp,
                    app_column: :ios_app_id,
                    snapshot_table: IpaSnapshot,
                    snapshot_column: :ipa_snapshot_id,
                    sdk_table: IosSdk,
                    sdk_column: :ios_sdk_id,
                    package_join_table: SdkPackagesIpaSnapshot
                }
            else
                {
                    app_table: AndroidApp,
                    app_column: :android_app_id,
                    snapshot_table: ApkSnapshot,
                    snapshot_column: :apk_snapshot_id,
                    sdk_table: AndroidSdk,
                    sdk_column: :android_sdk_id,
                    package_join_table: SdkPackagesApkSnapshot
                }
            end
        end

        def find_or_create_android_sdks_from_classes(classes:, read_only: true)
          sdks, paths = ANDROID_CLASS_CLASSIFIER.classify(classes)
          sdks = sdks.map do |sdk_info|
            sdk_name = sdk_info[0]
            sdk_website = sdk_info[1]
            sdk = AndroidSdk.find_by_name(sdk_name)
               if sdk.nil? and not read_only
              sdk = create_sdk_from_proposed(
                proposed: {name: sdk_name, website: sdk_website, open_source: false, github_repo_identifier: nil},
                platform: :android)
               elsif sdk.nil?
              next
               end
               sdk
          end.compact
          [sdks, paths]
        end


        # Given a list of packages (com.facebook.sdk, ...), return the sdks that exist and use google to find other ones. If create is turned on, will go ahead and create the sdks (should )
        def find_from_packages(packages:, platform:, snapshot_id:, read_only: false)
            # get references to tables
            map = platform_map(platform: platform)
            package_join_table = map[:package_join_table]
            snapshot_column = map[:snapshot_column]
            sdk_column = map[:sdk_column]

            packages = packages.uniq

            # add all packages to the join table
            if !read_only
        existing = SdkPackage.where(package: packages)
        existing_packages = existing.pluck(:package).map(&:downcase)
        missing = packages.select { |p| !existing_packages.include?(p.downcase) }
        rows = missing.map { |p| SdkPackage.new(package: p) }
        SdkPackage.import(
          rows,
          synchronize: rows,
          synchronize_keys: [:package]
        )
        join_rows = (existing + rows).map do |sdk_package|
          package_join_table.new(
            sdk_package_id: sdk_package.id,
            snapshot_column => snapshot_id
          )
        end
        package_join_table.import join_rows
            end

            matches = existing_sdks_from_packages(packages: packages, platform: platform)

            # update all the packages in the join table with the matching sdk
            if !read_only
                matches.each do |package, sdk|
                    SdkPackage.find_by_package(package).update(sdk_column => sdk.id)
                end
            end

            found_sdks = matches.values.uniq

      # disabled going forward
      # if still exists and is false as of 4/2017, feel free to remove it
      if ServiceStatus.is_active?(:ios_auto_sdk_creation)
        remaining = packages - matches.keys

        new_matches = create_sdks_from_packages(packages: remaining, platform: platform, read_only: read_only, snapshot_id: snapshot_id)

        if !read_only
          new_matches.each do |package_arr, sdk|
            package_arr.each do |package|
              SdkPackage.find_by_package(package).update(sdk_column => sdk.id)
            end
          end
        end

        new_sdks = new_matches.values.uniq
      else
        new_sdks = []
      end

            (found_sdks + new_sdks).uniq
        end

        # Lookup the packages in our current data to find any matches
        # @param packages - array of packages (ex: ['com.facebook.sdk', ...])
        # @param platform - :android or :ios
        # @result hash mapping package (string) to sdk (IosSdk or AndroidSdk)
        def existing_sdks_from_packages(packages:, platform:)

            col = platform_map(platform: platform)[:sdk_column]
            sdk_table = platform_map(platform: platform)[:sdk_table]

            regexes = SdkRegex.where.not(col => nil).map do |row|
                {
                    col => row[col],
                    regex: Regexp.new(row.regex, true) # true for case insensitive
                }
            end

      # load collective package requests
      package_rows = SdkPackage.where(package: packages)

            packages.reduce({}) do |memo, package|
                match = regexes.find {|entry| entry[:regex].match(package)}

                if match.nil?
          row = package_rows.find { |r| r.package.downcase == package.downcase } # case-insensitive
                    match = row if row && row[col]
                end

                memo[package] = sdk_table.find(match[col]) if match

                memo
            end
        end

        # Extract company name from a package (ex. "com.facebook.activity" => "facebook")
        def query_from_package(package_name)
        package = strip_prefix(package_name)
        return nil if package.blank?
        package = package.capitalize if package == package.upcase && package.count('.').zero?

        name = known_parent_query(package) || package.split('.').first

        return nil if name.nil?
        name = camel_split(name)

        return nil if name.nil? || name.length < QUERY_MINIMUM_LENGTH # no good if it's nil or less than QUERY_MINIMUM_LENGTH

        name
        end

        def create_sdks_from_packages(packages:, platform:, snapshot_id:,read_only: false)

            col = platform_map(platform: platform)[:sdk_column]

            # get mapping from query to array of packages
            query_hash = packages.reduce({}) do |memo, package|
                query = query_from_package(package)
        unless query.nil?
          existing = memo[query]
          memo[query] = existing.present? ? existing << package : [package]
                end
                memo
            end

            # get mapping from array of packages back to sdk (either existing or new)
            packages_to_sdk = query_hash.keys.reduce({}) do |memo, query|
                sdk = google_sdk(query: query, platform: platform, snapshot_id: snapshot_id) || google_github(query: query, platform: platform, snapshot_id: snapshot_id)

                unless sdk.nil?
                    existing = find_sdk_from_proposed(proposed: sdk, platform: platform)

                    if existing || read_only
                        memo[query_hash[query]] = existing if existing
                    else
                        sdk = create_sdk_from_proposed(proposed: sdk, platform: platform)
                        memo[query_hash[query]] = sdk
                    end
                end

                memo
            end
        end

        # checks to see if the proposed sdk matches something that exists in the database. If so, returns that sdk. Otherwise returns nil
        def find_sdk_from_proposed(proposed:, platform:)

            sdk_table = platform_map(platform: platform)[:sdk_table]

            return proposed if proposed.class == sdk_table

            # TODO: maybe revisit
            match = sdk_table.find_by_name(proposed[:name])
            return match if match

            match = sdk_table.find_by_website(proposed[:website])
            return match if match

            nil
        end

        # Creates the SDK from the proposed SDK or, if conflict, returns existing sdk
        # @param proposed - A hash for the sdk object
        # @param platform - :ios or :android
        # @returns ActiveRecord sdk object
        def create_sdk_from_proposed(proposed:, platform:)
      favicon = begin
        proposed[:favicon] || FaviconService.get_favicon_from_url(url: proposed[:website])
      rescue
        FaviconService.get_default_favicon
      end

            sdk = if platform == :ios
                begin
                    IosSdk.create!({
                        name: proposed[:name],
                        website: proposed[:website],
                        favicon: favicon,
                        open_source: proposed[:open_source],
                        github_repo_identifier: proposed[:github_repo_identifier],
                        source: IosSdk.sources[:package_lookup],
                        kind: :native
                    })
                rescue ActiveRecord::RecordNotUnique
                    IosSdk.find_by_name(proposed[:name])
                end
            else
        begin
          AndroidSdk.create!(
            name: proposed[:name],
            website: proposed[:website],
            favicon: favicon,
            open_source: proposed[:open_source],
            github_repo_identifier: proposed[:github_repo_identifier],
            kind: :native
          )
        rescue ActiveRecord::RecordNotUnique
          AndroidSdk.find_by_name(proposed[:name])
        end
            end

            sdk
        end

        # For a hard coded list of known parents, builds a query of more relevant information
        # @param package - "google.admob" (Notice no prefix)
        # @returns a query term like "Google admob"
        def known_parent_query(package)

            known_companies = %w(google facebook)

            known_companies.each do |co|
                if package.match(/#{co}/i)
                    return "#{co} #{package.split('.').select {|part| !part.match(/#{co}/i) }.first}"
                end
            end

            nil
        end

        # Get the url of an sdk if it is valid
        def google_sdk(query:, platform:, snapshot_id:)
            google_search(q: "#{query} #{platform} sdk", limit: 4, platform: platform).each do |url|
            company = query.capitalize
            return {website: url, name: company, open_source: false} if sdk_company_valid?(query: query, platform: platform, url: url, company: company, snapshot_id: snapshot_id)
            end
            nil
        end

        # Whether the SDK company is valid
        def sdk_company_valid?(query:, platform:, url:, company:, snapshot_id:)
            # Eliminate known companies
            known_companies = %w(
                Apple
                Github
                Bitbucket
                Sourceforge
        Android
            )

            return false if known_companies.include?(company)

            # if the proposed company exists in the app name, it's most likely not a real SDK
            app_name = get_app_name(platform: platform, snapshot_id: snapshot_id)
            begin
                return false if app_name.match(Regexp.new(company, true)) # case insensitive
            rescue RegexpError
                return false
            end

            return false if url.length > 170 # for mysql reasons...also if website url is that long, it's probably garbage 99% of the time

            begin
            # TODO, change this to catch mutliword examples "Google admob". Won't currently work but those are hard coded into regex table
                return false unless UrlHelper.full_domain(url).downcase.include?(query.downcase)
            rescue     # catch invalid URIs
                return false
            end

            true
        end

        # given a snapshot id and a platform, return the app name
        def get_app_name(platform:, snapshot_id:)
            map = platform_map(platform: platform)

            app_id = map[:snapshot_table].find(snapshot_id)[map[:app_column]]
            app_name = map[:app_table].find(app_id).name

            app_name || ""
        end

        # Get the url and company name of an sdk from github if it is valid

        def google_github(query:, platform:, snapshot_id:)
            return nil unless github_query_valid?(query)

            q = "#{query} #{platform}"
            google_search(q: q, site: 'github.com', platform: platform).each do |url|
                begin
                    url_re = Regexp.new(/https:\/\/github.com\/[^\/]*\/[^\/]*#{query}[^\/]*\z/i)
                rescue RegexpError
                    next
                end
                
                if !!(url =~ url_re)    # if matches format like https://github.com/MightySignal/slackiq
          rd = GithubApi.repo_info_from_url(url)
                    next if rd['message'] == 'Not Found'    # repository is not valid; try the next link

                    #select repo data (srd) that we're interested in
                    srd = {
                        repo_id: rd['id'],
                        repo_name: rd['name'],
                        repo_description: rd['description'],
                        repo_language: rd['language'],
                        repo_owner_id: rd['owner']['id'],
                        repo_owner_name: rd['owner']['login'],
                        repo_owner_type: rd['owner']['type']
                    }

                    if repo_name = srd[:repo_name]
                        dice_similarity = FuzzyMatch::Score::PureRuby.new(repo_name, query).dices_coefficient_similar
                        next if dice_similarity < DICE_SIMILARITY_THRESHOLD    # query not similar enough to repo name
                    end

                    company = query.capitalize
                    app_name = get_app_name(platform: platform, snapshot_id: snapshot_id)

                    next if app_name.match(/#{company}/i)

                    favicon = begin
            author = GithubApi.author_info_from_url(url)
                        website = author['blog'] if author && author['type'] == 'Organization' && author['blog']
                        FaviconService.get_favicon_from_url(url: website || 'http://github.com')
                    rescue
                        FaviconService.get_favicon_from_url(url: 'http://github.com', try_backup: false)
                    end

                    return {website: url, favicon: favicon, open_source: true, name: company, github_repo_identifier: srd['id']}.merge(srd)
                end
            end
            nil
        end

        def github_query_valid?(query)
            query = query.downcase

            invalid_queries = %w(
                apple
                queue
        android
            )
            return false if invalid_queries.include?(query)

            true
        end

        # q - string for the query (ex. 'parse ios')
        # site - string to of a domain to restrict search results (ex. 'github.com')
        def google_search(q:, site: nil, limit: 10, platform:)
          q = q.gsub(/[^\w\s]/, ' ')
          q = "site:#{site} " + q if site.present?

      # TODO: better platform decisions. should be able to split live scan from mass across platforms
      search = if platform == :ios
                 GoogleSearcher::Searcher.search(q, proxy_type: :general)
               else
                 BingSearcher::Searcher.new.search(q, proxy_type: :all_static)
               end
          search.results.map(&:url).take(limit)
        end

        def valid_domain?(url)
            url.exclude?('...') && url != '0' && url.count('-') <= 1
        end

        def exts(dot = nil)
      ext_arr = File.open('exts.txt') {|f| f.read}.split(/\n/)
            ext_arr.map{|e| dot == :before ? ".#{e}" : (dot == :after ? "#{e}." : e)}
        end

        def strip_prefix(package)
        package_arr = package.split(/\./)
        prefix = package_arr.first
        package_arr.shift if exts.include?(prefix) || prefix.blank?
        package_arr.join('.')
        end

        def camel_split(str)
            str.split(/(?=[A-Z])/).map(&:capitalize).join(' ').strip
        end

        #### FOR TESTING #####
        def find_source
            IosSdk.where('id > 2865').map do |sdk|
                snaps = IosSdksIpaSnapshot.where(ios_sdk_id: sdk.id).map {|x| x.snapshot}
                apps = snaps.map {|s| s.ios_app.name}.uniq
                {name: sdk.name, website: sdk.website, apps: apps}
            end
        end

    end
end
