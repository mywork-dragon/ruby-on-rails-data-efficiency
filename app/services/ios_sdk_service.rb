class IosSdkService

	DUMP_PATH = Rails.env.production? ? '/mnt/cocoapods/Specs' : '/tmp/cocoapods/Specs'
	MIN_DOWNLOADS = 1000

	class << self

		# override allows for updating regardless if last version hasn't changed
		def update_ios_sdks(override = false)
			return 'Git must be installed' if `which git`.chomp.blank?

			# Validate that update needs to happen
			repo_state = JSON.parse(open('https://api.github.com/repos/Cocoapods/Specs/branches/master').read())
			raise "Error communcating with Github #{state}" if repo_state["name"].nil?

			last_update = IosSdkUpdate.last

			if !override && !last_update.nil? && last_update.cocoapods_sha == repo_state["commit"]["sha"]
				return "Cocoapods have not changed since last update"
			end

			# Figure out which files changed (takes a while)
			# `git clone https://github.com/CocoaPods/Specs.git #{DUMP_PATH}`

			if last_update.nil?
				files = `ls #{File.join(DUMP_PATH, "Specs")}`.chomp.split("\n")
			else
				files = `cd #{DUMP_PATH} && git diff --name-only #{last_update.cocoapods_sha} Specs`.chomp.split("\n")
			end

			sdks = files.map {|x| x.split('/')[1]}
			new_sdks = sdks.select {|sdk| IosSdk.find_by_name(sdk).nil?}
			old_sdks = sdks - new_sdks

			# validate the new sdks and create them
			new_sdks.select! {|sdk| validate_sdk(sdk)}.map {|sdk| extract_pod_info(sdk)}.map {|pod| pod_to_row(pod)}.each do |row|
				IosSdk.create!(row)
			end

			# check the old ones, see if they've been deprecated
			old_sdks.select! do |sdk|
				# for now, assume that all modifications update the latest version. In the future, check to see that the latest version in directory has changed from what's in the cocoapods table
				pod = extract_pod_info(sdk)
				!check_deprecated(pod)
			end.map { |pod| pod_to_row(pod) }.each do |row|
				i = IosSdk.find_by_name(row[:name])
				row.keys.each {|key| i[key] = row[key]}
				i.save
			end

			# now that we've created SDKs, go through and create the cocoapods
			cocoapod_updates = old_sdks + new_sdks
			cocoapod_updates.select! do |sdk|
				i = IosSdk.find_by_name(sdk)
				i.cocoapods
			end
		end

		def pod_to_row(pod)
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

			uri = URI(uri)

			data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol=> uri.scheme}) do |curb|
				curb.follow_location = true
				curb.set :nobody, true
			end

			return false if data.status != 200

			# only count it if it meets a minimum number of downloads
			# Note: bitbucket downloads for whatever reason all have very diminished metrics
			if !(pod["git"] && pod["git"].include?("bitbucket"))

				uri = URI("http://metrics.cocoapods.org/api/v1/pods/#{name}.json")
				data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol=> uri.scheme})

				return false if data.status != 200

				json = JSON.parse(data)
				return false if json["stats"]["download_total"] < MIN_DOWNLOADS
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

			contents
		end
	end
end
