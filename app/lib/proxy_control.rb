class ProxyControl

  class << self
    def start_proxies
      toggle_proxies(activate: true)
    end

    def stop_proxies
      toggle_proxies(activate: false)
    end

    def rotate_all_proxies
      # Scales micro proxy fleet down to 10 instances and then back up to 110.
      puts 'Scaling down proxy fleet'
      MightyAws::InstanceControl.new.stop_all_proxies
      puts 'Allowing 4 minutes for proxy containers to stop and deregister from Route53'
      sleep 240

      activation_routine
    end

    def toggle_proxies(activate:)
      activate ? activation_routine : deactivation_routine
    end

    def deactivation_routine
      MightyAws::InstanceControl.new.stop_temporary_proxies
    end

    def activation_routine
      puts 'Starting temporary proxies'
      MightyAws::InstanceControl.new.start_temporary_proxies
      puts 'Allowing 4 minutes for proxy containers to spin up and register with Route53'
      sleep 240
    end
  end
end
