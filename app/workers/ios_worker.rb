module IosWorker

	WARNING_LEVEL_MAP = {
		'8' => 4000,
		'9' => 2000
	}

	def perform(ipa_snapshot_id, bid = nil)
	  execute_scan_type(ipa_snapshot_id: ipa_snapshot_id, bid: bid)
	end

	def execute_scan_type(ipa_snapshot_id:, bid:)
	  run_scan(ipa_snapshot_id: ipa_snapshot_id, purpose: @purpose, bid: bid, start_classify: @start_classify)
	end

	# convert data coming from ios_device_service to classdump row information
	def result_to_cd_row(data)
		data_keys = [
			:success,
			:duration,
			:install_time,
			:install_success,
			:dump_time,
			:dump_success,
			:teardown_success,
			:teardown_time,
			:error,
			:trace,
			:error_root,
			:error_teardown,
			:error_teardown_trace,
			:teardown_retry,
			:error_code
		]

		row = data.select { |key| data_keys.include? key }

		class_dump_file = File.open(data[:summary_path]) if Rails.env.production? && data[:summary_path]
		app_content_file = File.open(data[:app_contents_path]) if Rails.env.production? && data[:app_contents_path]

		row[:class_dump] = class_dump_file
		row[:app_content] = app_content_file

		row
	end

	def run_scan(ipa_snapshot_id:, purpose:, start_classify: false, bid:)

		# create database rows
		result = nil
		begin
			snapshot = IpaSnapshot.find(ipa_snapshot_id)

			return nil if snapshot.download_status == :complete # make sure no duplicates in the job

			app_identifier = IosApp.find(snapshot.ios_app_id).app_identifier
			lookup_content = JSON.parse(snapshot.lookup_content)
			raise "No app identifer for ios app #{snapshot.ios_app_id}" if app_identifier.nil?
			raise "No lookup content available for #{snapshot.ios_app_id}" if lookup_content.empty?

			snapshot.update(download_status: :starting) # update the status

			# return nil if snapshot.download_status == :complete # make sure no duplicates in the job

			# TODO: add logic to take previous results if app's version in the app store has not changed

			classdump = ClassDump.create!(ipa_snapshot_id: snapshot.id)

			# get a device
			puts "#{snapshot.ipa_snapshot_job_id}: Reserving device #{Time.now}"
			device = reserve_device(purpose: purpose, lookup_content: lookup_content)
			puts "#{snapshot.ipa_snapshot_job_id}: #{device ? ('Reserved device ' + device.id.to_s) : 'Failed to reserve'} #{Time.now}"

			# no devices available...fail out and save
			if device.nil?
				classdump.complete = true
				classdump.error_code = :devices_busy
				classdump.save

				return on_complete(ipa_snapshot_id: ipa_snapshot_id, bid: bid, result: classdump)
			end

			classdump.ios_device_id = device.id
			apple_account = AppleAccount.find_by_ios_device_id(device.id)
			raise "Device #{device.id} is not tied to an Apple Account. Device will be left in reserved state" if apple_account.blank?
			classdump.apple_account_id = apple_account.id
			classdump.save

			# do the actual classdump
			# after install and dump, will run the procedure block which updates the classdump table. 
			# Will be useful for polling or could add some logic to send status updates
			final_result = IosDeviceService.new(device).run(app_identifier,lookup_content, purpose, snapshot.id) do |incomplete_result|
				row = result_to_cd_row(incomplete_result)
				row[:complete] = false
				classdump.update row

				if row[:dump_success]
					snapshot.download_status = :cleaning
					snapshot.bundle_version = incomplete_result[:bundle_version]
					snapshot.save
					# don't start classifying while cleaning during development
					if start_classify
						classifier_class = if purpose == :one_off
							IosClassificationServiceWorker
						else
							IosMassClassificationServiceWorker
						end

						if Rails.env.production?
							unless batch.nil?
								batch.jobs do
									classifier_class.perform_async(snapshot.id)
								end
							else
								classifier_class.perform_async(snapshot.id)
							end
						else
							classifier_class.new.perform(snapshot.id)
						end
					end
				end
			end

			release_device(device)

			# upload the finished results
			row = result_to_cd_row(final_result)

			# the state of the file hasn't changed since update after dump (don't want to reupload file)
			row.delete(:class_dump) 
			row.delete(:app_content)

			row[:complete] = true
			classdump.update row

			# once we've finished uploading to s3, we can delete the files
			`rm -f #{final_result[:summary_path]}` if Rails.env.production? && final_result[:summary_path]
			`rm -f #{final_result[:app_contents_path]}` if Rails.env.production? && final_result[:app_contents_path]

			result = classdump

			# send notification if we've reached a threshold
			check_account_limits(device) if Rails.env.production?
		rescue => e
			result = e
		end

		on_complete(ipa_snapshot_id: ipa_snapshot_id, bid: bid, result: result)
	end

	def reserve_device(purpose:, lookup_content: nil)

		any = IosDevice.where(build_query(purpose: purpose, in_use: nil, requirements: lookup_content)).take

		raise "No devices compatible with requirements" if any.nil?

		query = build_query(purpose: purpose, in_use: false, requirements: lookup_content)

		if purpose == :one_off || purpose == :test
			device = IosDevice.transaction do

				d = IosDevice.lock.where(query).order(:last_used).first

				if d
					d.in_use = true
					d.last_used = DateTime.now
					d.save
				end
				d
			end
		else # mass

			device = nil

			start_time = Time.now

			while device.nil? && Time.now - start_time < 60 * 60 * 24 * 365 # 1 year

				puts "sleeping"
				sleep(Random.new.rand(7...13))

				device = IosDevice.transaction do

					d = IosDevice.lock.where(query).order(:last_used).first

					if d
						d.in_use = true
						d.last_used = DateTime.now
						d.save
					end
					d
				end
			end

		end

		device
	end

	# returns a string to be passed into a where query for devices based on lookup data
	# returns empty string if nothing required
	def build_query(purpose:, in_use: nil, requirements: nil)

		query_parts = []

		query_parts << "purpose = #{IosDevice.purposes[purpose]}"

		query_parts << "in_use = #{in_use}" if !in_use.nil?

		if !requirements.blank?
			query_parts << "ios_version_fmt >= '#{IosDevice.ios_version_to_fmt_version(requirements['minimumOsVersion'])}'" if !requirements['minimumOsVersion'].blank?
		end

		query_parts.join(' and ')
	end

	def release_device(device)
		device.in_use = false
		device.save
	end

	def check_account_limits(device)
		ios_major_version = device.ios_version.split(".").first

		warning_level = WARNING_LEVEL_MAP[ios_major_version]
		error_level = warning_level * 2

		return if warning_level.nil?

		apple_account = AppleAccount.find_by_ios_device_id(device.id)

		downloads_count = apple_account.class_dumps.count

		alert_frequency = device.purpose == 'one_off' ? 3 : 15

		message = if downloads_count == warning_level
			"*CAUTION*:exclamation:: AppleAccount #{apple_account.id} has crossed the #{warning_level} downloads threshold. *Check device #{device.id} for slowness*"
		elsif downloads_count >= error_level && (downloads_count - error_level) % alert_frequency == 0
			"*WARNING* :skull_and_crossbones:: AppleAccount #{apple_account.id} has crossed the limit of #{error_level} downloads. *Please reset the phone and it's Apple Account*"
		end

		Slackiq.message(message, webhook_name: :automated_alerts) unless message.nil?
	end

end