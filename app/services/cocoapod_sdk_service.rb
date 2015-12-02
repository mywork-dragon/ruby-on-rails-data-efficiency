class CocoapodSdkService

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
			`git clone https://github.com/CocoaPods/Specs.git #{DUMP_PATH}`
			# TODO: if ignored something because didn't meet download criteria, will not be added to database until next version comes out 
			# if last_update.nil?
			# 	sdks = `ls #{File.join(DUMP_PATH, "Specs")}`.chomp.split("\n")
			# else
			# 	sdks = `cd #{DUMP_PATH} && git diff --name-only #{last_update.cocoapods_sha} Specs`.chomp.split("\n").map { x.split('/')[1] }.uniq
			# end

			sdks = `ls #{File.join(DUMP_PATH, "Specs")}`.chomp.split("\n")

			i = IosSdkUpdate.create!(cocoapods_sha: repo_state["commit"]["sha"])

			if Rails.env.production?
				batch = Sidekiq::Batch.new
				batch.description = 'scraping the cocoapods repository'
				batch.on(:complete, 'CocoapodSdkService#on_complete')

				batch.jobs do
					sdks.each do |sdk|
						CocoapodSdkServiceWorker.perform_async(sdk, i.id)
					end
				end
				
			else
				sdks.sample(5) do |sdk|
					CocoapodSdkServiceWorker.new.perform(sdk, i.id)
				end
			end

			`rm -rf #{DUMP_PATH}`

		end

		def run_broken(update_id: nil, names: nil, non_existing_only: true)
			names = if update_id.present?
				names = IosSdkUpdateException.where("ios_sdk_update_id=#{update_id}").map {|x| x.sdk_name}

				if non_existing_only
					names.select! {|name| IosSdk.find_by_name(name).blank?}.uniq
				else
					names.uniq!
				end
			elsif names.present?
				names
			else
				return "Nothing to run"
				nil
			end

			if Rails.env.production?

				batch = Sidekiq::Batch.new
				batch.description = "retrying failed cocoapod runs" 
				batch.on(:complete, 'CocoapodSdkService#broken_on_complete')

				batch.jobs do
				  names.each do |name|
				  	CocoapodSdkServiceWorker.perform_async(name, update_id)
				  end
				end
			else
				return names
				CocoapodSdkServiceWorker.new.perform(names.sample, update_id)
			end
		end

		# def run_broken(update_id, repeated = false, names = nil)

		# 	names = IosSdkUpdateException.where("ios_sdk_update_id=#{update_id}").map {|x| x.sdk_name} if names.nil?

		# 	names.uniq.each do |sdk_name|
		# 		if Rails.env.production?
		# 			CocoapodSdkServiceWorker.perform_async(sdk_name, update_id)
		# 		else
		# 			CocoapodSdkServiceWorker.new.perform(sdk_name, update_id)
		# 		end
		# 	end

			
		# end
	end

	def on_complete(status, options)
		Slackiq.notify(webhook_name: :main, status: status, title: 'cocoapods scrape')
	end

	def broken_on_complete(status, options)
		Slackiq.notify(webhook_name: :main, status: status, title: 'cocoapods scrape')
	end


end
