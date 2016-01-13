class IosMonitorService

  class << self

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
  end
end