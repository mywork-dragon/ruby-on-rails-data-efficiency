class IosSdkServiceWorker

	include Sidekiq::Worker

	sidekiq_options :retry => 2, queue: :default

	MIN_DOWNLOADS = 500
	BACKTRACE_SIZE = 5

	def perform(sdk_name, update_id)
		begin
			update_sdk(sdk_name)
		rescue => e
			backtrace = e.backtrace[0...BACKTRACE_SIZE].join(' ---- ')

			IosSdkUpdateExceptions.create!({
				sdk_name: sdk_name,
				ios_sdk_updates_id: update_id,
				error: e.message,
				backtrace: backtrace
			})

			raise e
		end
	end

	def update_sdk(sdk_name)

		in_database = !IosSdk.find_by_name(sdk_name).nil?
		pod = get_pod_contents(sdk_name)
		if in_database
			# know it's valid, just check deprecated and update stuff
			i = IosSdk.find_by_name(sdk_name)

			if check_deprecated(pod)
				i.deprecated = true
				i.save
				return "SDK has been deprecated"
			end

			# update info
			row = pod_to_ios_sdk_row(pod)
			row.keys.each { |key| i[key] = row[key] }
			i.save
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
			if Rails.env.production?
				CocoapodDownloadWorker.perform_async(c.id)
			else
				CocoapodDownloadWorker.new.perform(c.id)
			end
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

		# TODO: go from git@... to https://www.(github|bitbucket).com/...
		# only ~30 sdks do it and they aren't important ones
		begin
			uri = URI(uri)
		rescue
			return "URL is not valid"
		end

		data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol=> uri.scheme}) do |curb|
			curb.follow_location = true
			curb.set :nobody, true
			curb.max_redirects = 50
		end

		return "URL is not available" if data.status != 200

		# only count it if it meets a minimum number of downloads
		# Note: bitbucket downloads for whatever reason all have very diminished metrics
		if !(pod["git"] && pod["git"].include?("bitbucket"))

			uri = URI("http://metrics.cocoapods.org/api/v1/pods/#{pod['name']}.json")

			data = Proxy.get_from_url("http://metrics.cocoapods.org/api/v1/pods/#{pod['name']}.json")

			return "Could not get metrics on the pod" if data.status != 200

			json = JSON.parse(data.body)

			# throws out new ones...but low bar means if they're good, they'll get picked up eventually
			return "Does not have stats or does not have required number of downloads" if json["stats"].nil? || json["stats"]["download_total"] < MIN_DOWNLOADS
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

	def pod_to_ios_sdk_row(pod)
		website = pod['homepage'] || pod["http"]
		name = pod['name']
		summary = pod['summary']

		# get the favicon
		begin
			favicon_url = WWW::Favicon.new.find(website)
		rescue
			favicon_url = nil
		end

		# determine open source
		open_source = website.match(/(?:bitbucket|github|sourceforge)/) ? true : false
		deprecated = check_deprecated(pod)

		{
			name: name,
			website: website,
			summary: summary,
			favicon: favicon_url,
			open_source: open_source,
			deprecated: deprecated
		}
	end


	def get_pod_contents(sdk_name, version = nil)

		if version.nil?
			# Get the latest version
			versions = GithubService.get_contents("Cocoapods/Specs", "Specs/#{sdk_name}")

			raise "Error getting pod #{sdk_name} with response: #{JSON.generate(versions)}" if versions.class != Array # expecting directory

			version = versions.sort_by { |x| x["name"] }.last["name"]
		end
		filename = "#{sdk_name}.podspec.json"
		res = GithubService.get_contents("Cocoapods/Specs", "Specs/#{sdk_name}/#{version}/#{filename}")

		raise "Error getting pod #{sdk_name} of version #{version || "Nil"} with response: #{JSON.generate(res)}" if res.class != String

		begin
			pod = JSON.parse(res)
		rescue => e
			raise "Unexpected malformed pod json: #{res}"
		end

		pod["git"] = pod["source"]["git"]
		pod["http"] = pod["source"]["http"]
		pod["tag"] = pod["source"]["tag"]

		pod
	end

end
