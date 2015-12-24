class IosMonitorService

  class << self

    def check_hanging_mass_ssh

      times = {}      
      devices = IosDevice.where(purpose: IosDevice.purposes[:mass]).find_each do |device|
        times[device.id] = IosDeviceService.new(device).get_ssh_times
      end

      ap times
    end

    def kill_ssh_sessions(ids:)

      devices = IosDevice.where(id: ids).find_each do |device|
        result = IosDeviceService.new(device).kill_ssh_session
        ap "Device #{device.id}: #{result}"
      end
    end
  end
end