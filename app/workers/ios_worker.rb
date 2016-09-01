module IosWorker

	WARNING_LEVEL_MAP = {
		'8' => 3000,
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
      :account_success,
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
    result, reserver = nil, nil
    snapshot = IpaSnapshot.find(ipa_snapshot_id)

    return nil if snapshot.download_status == :complete # make sure no duplicates in the job

    ios_app = IosApp.find(snapshot.ios_app_id)
    app_identifier = ios_app.app_identifier
    lookup_content = JSON.parse(snapshot.lookup_content)
    raise "No app identifer for ios app #{snapshot.ios_app_id}" if app_identifier.nil?
    raise "No lookup content available for #{snapshot.ios_app_id}" if lookup_content.empty?

    snapshot.update(download_status: :starting) # update the status

    # return nil if snapshot.download_status == :complete # make sure no duplicates in the job

    # TODO: add logic to take previous results if app's version in the app store has not changed

    classdump = ClassDump.create!(ipa_snapshot_id: snapshot.id)

    # get a device
    puts "#{snapshot.ipa_snapshot_job_id}: Reserving device and account #{Time.now}"
    reserver = IosReserver.new(ios_app: ios_app, app_store: snapshot.app_store)
    reserver.reserve(purpose, lookup_content)
    device = reserver.device
    apple_account = reserver.apple_account
    a_device_already_configured = reserver.a_device_already_configured?
    puts "#{snapshot.ipa_snapshot_job_id}: #{device ? ('Reserved device ' + device.id.to_s) : 'Failed to reserve'}"
    puts "#{snapshot.ipa_snapshot_job_id}: #{apple_account ? ('Reserved apple_account ' + apple_account.id.to_s) : 'Failed to reserve'}"
    puts "#{snapshot.ipa_snapshot_job_id}: a_device_already_configured: #{a_device_already_configured}"
    puts Time.now

    # no devices available...fail out and save
    if device.nil?
      classdump.complete = true
      classdump.error_code = :devices_busy
      classdump.save

      return on_complete(ipa_snapshot_id: ipa_snapshot_id, bid: bid, result: classdump)
    end

    # attach ios_device and apple_account to classdump
    classdump.ios_device_id = device.id
    fail "Could not reserve an Apple Account. Device will be left in reserved state" if apple_account.blank?
    classdump.apple_account_id = apple_account.id
    classdump.save

    if a_device_already_configured
      apple_account_to_switch_to = nil
      account_changed_lambda = -> { } # no =-op
    else
      apple_account_to_switch_to = apple_account
      account_changed_lambda = -> { reserver.account_changed }
    end

    # do the actual classdump
    # after install and dump, will run the procedure block which updates the classdump table. 
    # Will be useful for polling or could add some logic to send status updates
    final_result = IosDeviceService.new(device, apple_account: apple_account_to_switch_to, account_changed_lambda: account_changed_lambda).run(app_identifier,lookup_content, purpose, snapshot.id) do |incomplete_result|
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

    reserver.release

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
    check_account_limits(device: device, apple_account: apple_account) if Rails.env.production?
  rescue => e
    result = e
  ensure
    reserver.release if defined?(reserver) && !reserver.released?
		on_complete(ipa_snapshot_id: ipa_snapshot_id, bid: bid, result: result)
	end

	def check_account_limits(device:, apple_account:)
		ios_major_version = device.ios_version.split(".").first

		warning_level = WARNING_LEVEL_MAP[ios_major_version]
		error_level = warning_level * 2

		return if warning_level.nil?

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
