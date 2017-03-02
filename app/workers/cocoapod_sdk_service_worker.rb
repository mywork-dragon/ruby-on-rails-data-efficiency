class CocoapodSdkServiceWorker

	include Sidekiq::Worker

	sidekiq_options :retry => 2, queue: :default

	MIN_OS_DOWNLOADS = 500
	MIN_COMPANY_DOWNLOADS = 250
	BACKTRACE_SIZE = 5
	OS_URL_REGEX = /(?:bitbucket|github|sourceforge)/

	def perform(sdk_name, update_id)
		begin
			update_sdk(sdk_name)
		rescue => e

			IosSdkUpdateException.create!({
				sdk_name: sdk_name,
				ios_sdk_update_id: update_id,
				error: e.message,
				backtrace: e.backtrace
			})

			raise e
		end
	end

	def update_sdk(sdk_name)

		in_database = !IosSdk.find_by_name(sdk_name).nil?
		pod = get_pod_contents(sdk_name)
		
		if in_database
			# know it's valid, just check deprecated and update stuff
			i = IosSdk.find_by_name!(sdk_name)

      # NOTE: turn off overwrite protection
			# if check_deprecated(pod)
			# 	i.deprecated = true
			# 	i.save
			# 	return "SDK has been deprecated"
			# end

			# update info
			row = pod_to_ios_sdk_row(pod)
			row.keys.each { |key| i[key] = row[key] }
      i.save!
		else
			result = validate_sdk(pod)
			return result if result != true

			row = pod_to_ios_sdk_row(pod)
			IosSdk.create!(row)
		end

		# If haven't exited, can begin process of creating cocoapod
		i = IosSdk.find_by_name(sdk_name)
		most_recent = i.cocoapods.sort_by { |x| x.version }.last

		if !pod['version'].nil? && (most_recent.nil? || most_recent.version < pod['version'])
			row = pod_to_cocoapod_row(pod)
			row[:ios_sdk_id] = i.id

			c = Cocoapod.create!(row)
      # NOTE: temporarily doing it synchronously to allow one off requests
      CocoapodDownloadWorker.new.perform(c.id)
			# if Rails.env.production?
			# 	CocoapodDownloadWorker.perform_async(c.id)
			# else
			# 	CocoapodDownloadWorker.new.perform(c.id)
			# end
		else
			return "Latest cocoapod already exists"
		end


	end

	# Returns true if the sdk is valid
	# Otherwise returns a string explaining why it failed
	def validate_sdk(pod)

		# prove it isn't deprecated
		return "Is deprecated" if check_deprecated(pod)

		# if it specifies platforms...make sure it supports ios
		platforms = pod["platforms"]
		if platforms
			return "Does not support ios" if platforms.class == String && platforms != "ios"
			return "Does not support ios" if platforms.class == Hash && !platforms.keys.include?("ios")
		end

		# make sure the source link isn't dead
		uri = pod["http"] || pod["git"]
		return "Does not have an available url" if uri.nil?

		# bitbucket returns a 200 even for not available repos so use their API instead (60000 per hour rate limit)
		if uri.include?("bitbucket")
			data = Proxy.get_from_url(File.join("https://api.bitbucket.org/2.0/repositories/", uri.path.gsub(/.git$/, '')))
		else
      data = HTTParty.head(
        uri,
        follow_redirects: true
      )
		end

		return "URL is not available" if data.code != 200

		# only count it if it meets a minimum number of downloads
		# Note: bitbucket downloads for whatever reason all have very diminished metrics
		if !(pod["git"] && pod["git"].include?("bitbucket"))
      json = CocoapodMetricsApi.metrics(pod['name'])
			# throws out new ones...but low bar means if they're good, they'll get picked up eventually
      # DISABLE FOR NOW
			# return "Does not have stats or does not have required number of downloads" if json["stats"].nil? || below_minimum_threshold?(pod,json["stats"]["download_total"])
		end

		true
	end

	def check_deprecated(pod)
		pod['deprecated'] == true || !pod['deprecated_in_favor_of'].nil?
	end

	def pod_to_cocoapod_row(pod)
		{
			version: pod['version'],
			git: pod['git'],
			http: pod['http'],
			tag: pod['tag'],
			json_content: pod.to_json
		}
	end

	def get_website(pod)
		pod['homepage'] || pod["http"] || ""
	end

	def get_favicon_from_pod(pod:)

		website = get_website(pod)

		favicon = begin
			if website.match(/github\.com/)
        author = GithubApi.author_info_from_url(website)
				website = author['blog'] if author && author['type'] == 'Organization' && author['blog']
			end

			FaviconService.get_favicon_from_url(url: website)
		rescue
			FaviconService.get_default_favicon
		end

		favicon

	end

	def get_source(pod)
		pod['http'] || pod['git'] || ""
	end

	def is_open_source?(pod)

		source = get_source(pod)

		source.match(OS_URL_REGEX) ? true : false
	end

	def pod_to_ios_sdk_row(pod)
		website = get_website(pod)
		name = pod['name']
		summary = pod['summary']

		# get the favicon
		favicon_url = get_favicon_from_pod(pod: pod)

		open_source = is_open_source?(pod)
		deprecated = check_deprecated(pod)
		source = get_source(pod)

		# if github, get the repo identifier
		github_repo_identifier = if /github\.com/.match(source)

			begin
        GithubApi.repo_data_from_url(source)['id']
			rescue
				nil
			end
		end

		{
			name: name,
			website: website,
			summary: summary,
			favicon: favicon_url,
			open_source: open_source,
			deprecated: deprecated,
			github_repo_identifier: github_repo_identifier,
			source: IosSdk.sources[:cocoapods],
      kind: IosSdk.kinds[:native]
		}
	end


	def get_pod_contents(sdk_name, version = nil)

    pod = CocoapodSpecs.new.pod(sdk_name, version: version)

		# custom properties moved to the top level
		pod['git'] = pod['source']['git']
		pod['http'] = pod['source']['http']
		pod['tag'] = pod['source']['tag']

		pod
	end

	def below_minimum_threshold?(pod, downloads)
		downloads < (is_open_source?(pod) ? MIN_OS_DOWNLOADS : MIN_COMPANY_DOWNLOADS)
	end

end
