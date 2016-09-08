class ProxyControl
  def start_proxies
    activate_proxies(activate: true)
  end

  def stop_proxies
    toggle_proxies(activate: false)
  end

  def toggle_proxies(activate:)
    activate ? activation_routine : deactivation_routine
  end

  def deactivation_routine
    MightyAws::InstanceControl.stop_temporary_proxies
  end

  def activation_routine
    MightyAws::InstanceControl.start_temporary_proxies
    sleep 10 # let proxies spin up and start running
    MightyAws::Api.new.register_temp_proxies_with_proxy_lbs
    sleep 35 # register unregistered proxies. Health check is every 30 seconds
  end

end
