class IosSdkService

	DUMP_PATH = Rails.env.production? ? '/mnt/cocoapods/Specs' : '/tmp/cocoapods/Specs'
	
	class << self

		# override allows for updating regardless if last version hasn't changed
		def update_ios_sdks(override = false)
			return 'Git must be installed' if `which git`.chomp.blank?

			# Validate that update needs to happen
			# TODO: use github service api
			repo_state = JSON.parse(open('https://api.github.com/repos/Cocoapods/Specs/branches/master').read())
			raise "Error communcating with Github #{state}" if repo_state["name"].nil?

			last_update = IosSdkUpdate.last

			if !override && !last_update.nil? && last_update.cocoapods_sha == repo_state["commit"]["sha"]
				return "Cocoapods have not changed since last update"
			end

			# Figure out which files changed (takes a while)
			# `git clone https://github.com/CocoaPods/Specs.git #{DUMP_PATH}`

			if last_update.nil?
				sdks = `ls #{File.join(DUMP_PATH, "Specs")}`.chomp.split("\n")
			else
				sdks = `cd #{DUMP_PATH} && git diff --name-only #{last_update.cocoapods_sha} Specs`.chomp.split("\n").map { x.split('/')[1] }.uniq
			end


			# Send all of them to ios_sdk_service_worker with the hash

			# sdks = files.map {|x| x.split('/')[1]}
			# new_sdks = sdks.select {|sdk| IosSdk.find_by_name(sdk).nil?}
			new_sdks = sdks
			old_sdks = sdks - new_sdks
			byebug

			# validate the new sdks and create them
			new_sdks.select! {|sdk| validate_sdk(sdk)}.map {|sdk| extract_pod_info(sdk)}.map {|pod| pod_to_ios_sdk_row(pod)}.each do |row|
				IosSdk.create!(row)
			end
			byebug

			# check the old ones, see if they've been deprecated
			old_sdks.select! do |sdk|
				pod = extract_pod_info(sdk)
				deprecated = check_deprecated(pod)

				if deprecated
					i = IosSdk.find_by_name(sdk)
					i.deprecated = true
					i.save
				end

				!deprecated # select by the non deprecated
			end.map { |sdk| extract_pod_info(sdk) }.map { |pod| pod_to_ios_sdk_row(pod) }.each do |row|
				i = IosSdk.find_by_name(row[:name])
				row.keys.each {|key| i[key] = row[key]}
				i.save
			end

			# now that we have the SDKs, go through and create the cocoapods

			created = []
			cocoapod_updates = (old_sdks + new_sdks).uniq.each do |sdk|
				i = IosSdk.find_by_name(sdk)
				pod = extract_pod_info(sdk)

				most_recent = i.cocoapods.sort_by { |x| x.version }.last


				if !pod['version'].nil? && (most_recent.nil? || most_recent.version <= pod['version'])
					row = pod_to_cocoapod_row(pod)
					row[:ios_sdk_id] = i.id

					c = Cocoapod.create!(row)

					if Rails.env.production?
						CocoapodServiceWorker.perform_async(c.id)
					else
						# CocoapodServiceWorker.new.perform(c.id)
						created.push[pod['name']]
					end
				end
			end

			# IosSdkUpdate.create!(repo_state["commit"]["sha"])
			# byebug
			created
		end

		def pod_to_cocoapod_row(pod)
			{
				version: pod['version'],
				git: pod['git'],
				http: pod['http'],
				tag: pod['tag']
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

		def check_deprecated(pod)
			pod['deprecated'] == true || !pod['deprecated_in_favor_of'].nil?
		end

		def validate_sdk(name)

			pod = extract_pod_info(name)

			# prove it isn't deprecated
			return false if check_deprecated(pod)

			# if it specifies platforms...make sure it supports ios
			return false if !pod["platforms"].nil? && pod["platforms"]["ios"].nil?

			# make sure the source link isn't dead
			uri = pod["http"] || pod["git"]
			return false if uri.nil?

			# TODO: go from git@... to https://www.(github|bitbucket).com/...
			# only ~30 sdks do it and they aren't important ones
			begin
				uri = URI(uri)
			rescue
				return false
			end

			data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol=> uri.scheme}) do |curb|
				curb.follow_location = true
				curb.set :nobody, true
			end

			return false if data.class == String || data.status != 200

			# only count it if it meets a minimum number of downloads
			# Note: bitbucket downloads for whatever reason all have very diminished metrics
			if !(pod["git"] && pod["git"].include?("bitbucket"))

				uri = URI("http://metrics.cocoapods.org/api/v1/pods/#{name}.json")
				data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol=> uri.scheme})

				return false if data.status != 200


				json = JSON.parse(data.body)

				# throws out new ones...but low bar means if they're good, they'll get picked up eventually
				return false if json["stats"].nil? || json["stats"]["download_total"] < MIN_DOWNLOADS
			end

			true
		end

		def extract_pod_info(name)
			path = File.join(DUMP_PATH, "Specs", name)
			latest_podspec_path = Dir.glob(File.join(DUMP_PATH, "Specs", name, "**/*.json")).sort.last
			contents = JSON.parse(File.open(latest_podspec_path) {|f| f.read})

			# move some nested properties up
			contents["git"] = contents["source"]["git"]
			contents["http"] = contents["source"]["http"]
			contents["tag"] = contents["source"]["tag"]
			# byebug
			contents
		end
	end
end
