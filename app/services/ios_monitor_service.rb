class IosMonitorService

  class << self

    def delete_old_classdumps
      `#{File.join(Rails.root, 'server', 'ios_utils', 'dark_side_clean.sh')}`
    end

    def check_hanging_mass_ssh

      times = {}      
      devices = IosDevice.where(purpose: IosDevice.purposes[:mass]).find_each do |device|
        ap "Starting device #{device.id}"
        times[device.id] = IosDeviceService.new(device).get_ssh_times
      end

      times
    end

    def kill_ssh_sessions(ids:)

      devices = IosDevice.where(id: ids).find_each do |device|
        result = IosDeviceService.new(device).kill_ssh_session
        ap "Device #{device.id}: #{result}"
      end
    end

    def check_apple_accounts
      accts = AppleAccount.where.not(ios_device_id: nil)

      accts.inject({}) do |mem, acct|
        mem[acct.ios_device_id] = acct.class_dumps.count
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

      log_path = File.join(ENV['HOME'], 'sidekiq.log')
      failures = `cat #{log_path} | grep 'sec downtime' | awk '{print $1}'`.split("\n")
      last_failure = failures.last
      return if last_failure.blank? || last_failure.chomp.blank?

      # puts "Last failure: #{last_failure}"

      begin
        fail_time = Time.parse(last_failure.chomp)
      rescue ArgumentError => e
        puts "parse failure: #{e.message}"
        return
      end

      # default wait time: 1 hour
      # puts "fail time: #{fail_time}"
      return unless fail_time <= Time.now - wait_time

      # find any devices stuck on in_use
      stuck_devices = IosDevice.where(purpose: IosDevice.purposes[:mass], in_use: true).where('last_used < ?', Time.now - wait_time)

      num_stuck = stuck_devices.count

      return if num_stuck == 0

      puts "#{Time.now.utc}: Rescuing #{num_stuck} phones"
      stuck_devices.update_all(in_use: false)

      Slackiq.message("Redis tunnel failed at #{fail_time.getlocal}. Found #{num_stuck} devices stuck. Re-enabled. *Check to see if devices are unlocked*", webhook_name: :automated_alerts)
    end

    def attempt_tar
      Net::SSH.start('localhost', 'root', :password => 'padmemyboo', :port => 2222) do |ssh|

        res1 = ssh.exec!("pushd /var/mobile/Containers/Bundle/Application/D331B0E0-6507-4560-BAFD-89E47BE5E3EF/ && find . > ms_file_tree.txt")
        res2 = ssh.exec!("pushd /var/mobile/Containers/Bundle/Application/D331B0E0-6507-4560-BAFD-89E47BE5E3EF/ && find . -type f -exec grep . \"{}\" -Iq \\\; -and -print0 | tar cfz ms_contents.tgz --null -T -")
        `/usr/local/bin/sshpass -p padmemyboo scp -P 2222 root@localhost:/var/mobile/Containers/Bundle/Application/D331B0E0-6507-4560-BAFD-89E47BE5E3EF/ms_contents.tgz .`
        byebug
      end
    end


  end
end