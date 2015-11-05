class IosSdkService

	DUMP_PATH = Rails.env.production? ? File.join(`echo $HOME`.chomp, '/cocoapods/Specs') : '/tmp/cocoapods/Specs'
	
	class << self

		# override allows for updating regardless if last version hasn't changed
		def update_ios_sdks(override = false)
			return 'Git must be installed' if `which git`.chomp.blank?

			# Validate that update needs to happen
			repo_state = GithubService.get_branch_data('Cocoapods/Specs', 'master')
			raise "Error communcating with Github #{repo_state.to_s}" if repo_state["name"].nil?

			last_update = IosSdkUpdate.last
			current_sha = repo_state["commit"]["sha"]

			if !override && !last_update.nil? && last_update.cocoapods_sha == current_sha
				return "Cocoapods have not changed since last update"
			end

			# Figure out which files changed (takes a while)
			# `git clone https://github.com/CocoaPods/Specs.git #{DUMP_PATH}`
			# TODO: if ignored something because didn't meet download criteria, will not be added to database until next version comes out 
			# if last_update.nil?
			# 	sdks = `ls #{File.join(DUMP_PATH, "Specs")}`.chomp.split("\n")
			# else
			# 	sdks = `cd #{DUMP_PATH} && git diff --name-only #{last_update.cocoapods_sha} Specs`.chomp.split("\n").map { x.split('/')[1] }.uniq
			# end

			sdks = `ls #{File.join(DUMP_PATH, "Specs")}`.chomp.split("\n")

			i = IosSdkUpdate.create!(repo_state["commit"]["sha"])

			if Rails.env.production?
				sdks.each do |sdk|
					IosSdkServiceWorker.perform_async(sdk, i.id)
				end
			else
				sdks.sample(5) do |sdk|
					IosSdkServiceWorker.new.perform(sdk, i.id)
				end
			end

			`rm -rf #{DUMP_PATH}`

		end
	end
end
