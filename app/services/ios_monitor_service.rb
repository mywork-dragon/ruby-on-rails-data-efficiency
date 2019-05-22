# Used in Cron
class IosMonitorService

  DEVICE_USERNAME = 'root'
  DEVICE_PASSWORD = 'padmemyboo'
  APPS_INSTALL_PATH = "/var/mobile/Containers/Bundle/Application/"

  class << self

    def delete_old_classdumps
      `#{File.join(Rails.root, 'server', 'ios_utils', 'dark_side_clean.sh')}`
    end

    def check_hanging_mass_ssh

      times = {}
      devices = IosDevice.where(purpose: IosDevice.purposes[:mass]).find_each do |device|
        ap "Starting device #{device.id}"
        times[device.id] = IosDownloadDeviceService.new(device, apple_account: device.apple_account).get_ssh_times
      end

      times
    end

    def kill_ssh_sessions(ids:)

      devices = IosDevice.where(id: ids).find_each do |device|
        result = IosDownloadDeviceService.new(device, apple_account: device.apple_account).kill_ssh_session
        ap "Device #{device.id}: #{result}"
      end
    end

    def check_apple_accounts
      accts = AppleAccount.where(kind: AppleAccount.kinds[:static]).where.not(ios_device_id: nil)
      accts += AppleAccount.where(kind: AppleAccount.kinds[:flex])

      accts.inject({}) do |mem, acct|
        mem[acct.id] = acct.class_dumps.count
        mem
      end
    end

    # Checks to see if the redis tunnel failed and resets if they are stuck in use
    def broken_redis_fix
      wait_time = 1.hour

      queues = %w(ios_epf_mass_scan ios_mass_scan)
      waiting_jobs = 0

      queues.each do |name|
        waiting_jobs += Sidekiq::Queue.new('ios_mass_scan').size
      end

      # puts "Jobs waiting: #{waiting_jobs}"

      return if waiting_jobs <= 0

      # find any devices stuck on in_use
      stuck_devices = IosDevice.where(purpose: IosDevice.purposes[:mass], in_use: true).where('last_used < ?', Time.now - wait_time)

      num_stuck = stuck_devices.count
      ids = stuck_devices.pluck(:id)

      return if num_stuck == 0

      logger = JsonLogger.new(
        filename: Rails.application.config.dark_side_json_log_path,
      )

      puts "#{Time.now.utc}: Rescuing #{num_stuck} phones"
      stuck_devices.each do |ios_device|
        puts "Trying device #{ios_device.id}"
        ios_device.update(disabled: true)
        IosDownloadDeviceService.new(ios_device, apple_account: ios_device.apple_account, logger: logger).kill_ssh_session
      end

      Slackiq.message("Found #{num_stuck} devices stuck: #{ids.join(', ')}. Killed SSH session and disabled. *Check device and re-enable when ready*", webhook_name: :automated_alerts)
    end

    def delete_ios_remnants(ios_device_ids: nil)
      raise 'Cannot use after 9.3.3 . Rewrite needed'
      ios_device_ids = IosDevice.where(purpose: IosDevice.purposes[:mass]).pluck(:id) if ios_device_ids.nil?

      devices = IosDevice.where(id: ios_device_ids)

      devices.each do |device|
        ap "Running Device #{device.id}: #{device.ip}"

        begin
          Net::SSH.start(device.ip, DEVICE_USERNAME, :password => DEVICE_PASSWORD) do |ssh|
            resp = ssh.exec!("ls #{APPS_INSTALL_PATH} | wc -l").chomp

            puts "Found #{resp} entries in apps folder"

            if resp.to_i != 0
              ssh.exec!("cd #{APPS_INSTALL_PATH} && find . -mindepth 3 -maxdepth 3 -exec rm -rf \"{}\" \\\;")
              remaining = ssh.exec!("cd #{APPS_INSTALL_PATH} && find . -mindepth 3 -maxdepth 3 | wc -l").chomp.to_i
              raise "Expected 0 files remaining. Found #{remaining}" if remaining != 0
            end

            puts "Now cleaning ~/ directory"

            files = [
              "Documents",
              "tmp",
              "logs"
            ]

            files.each do |file|
              puts "Cleaning ~/#{file}"
              resp = ssh.exec!("find ~/#{file} -mindepth 1 -maxdepth 1 2>/dev/null | wc -l").chomp

              puts "Found #{resp} entries in ~/#{file}"

              if resp.to_i != 0
                ssh.exec!("find ~/#{file} -maxdepth 1 -mindepth 1 -exec rm -rf \"{}\" \\\;")
                remaining = ssh.exec!("find ~/#{file} -mindepth 1 | wc -l").chomp.to_i
                raise "Expected 0 files remaining. Found #{remaining}" if remaining != 0
              end
            end

            puts "Finished"
          end
        rescue => e
          raise e
        end
      end
    end
  end
end
