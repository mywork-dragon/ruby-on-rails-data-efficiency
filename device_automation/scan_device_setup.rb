# Functions to automate the setup process for our devices in the lab.
# (Currently only iOS 10.1.1 is supported)
#
# The three main steps are:
#   - Install Cydia packages
#   - Clean device using iCleaner
#   - Setup proper device settings and register device in db

class ScanDeviceSetup

  def initialize(ip, device_id, web_driver_agent_path, port: 8100)
    @ip = ip
    @port = port
    @device_id = device_id
    @web_driver_agent_path = web_driver_agent_path
  end

  def run_cydia_installs(automated: true)
    client = WebDriverAgentClient.new(@ip, @port)
    client.start_remote(@device_id, @web_driver_agent_path)
    client.start_session('com.saurik.Cydia')

    with_user_prompt(
        before: "Checking for Upgrade Essential alert", 
        after: "Done checking for alert.", 
        error: "Error: just navigate to the Cydia homepage and press enter...",
        automated: automated) do
      begin
        client.tap_element(label: 'Upgrade Essential')
        client.tap_element(label: 'Continue Queuing', element_type: "Link")
        client.tap_element(label: 'Search') if return_to_search
        sleep 5
      rescue WebDriverAgentClient::WebDriverAgentError => e
        puts e.message
      end
    end

    with_user_prompt(
        before: "Queueing Cycript", 
        after: "Done queuing Cycript.", 
        error: "Error: Please queue Cycript and return to the Cydia search page and press enter...",
        automated: automated) do
      modify_cydia_app(client, 'Cycript', expected_version: '0.9.594')
    end

    with_user_prompt(
        before: "Queueing iClenaer", 
        after: "Done queuing iCleaner.", 
        error: "Error: Please queue iCleaner and return to the Cydia search page and press enter...",
        automated: automated) do
      queue_cydia_app(client, 'iCleaner')
    end

    with_user_prompt(
        before: "Queueing Open", 
        after: "Done queuing Open.", 
        error: "Error: Please queue Open and return to the Cydia search page and press enter...",
        automated: automated) do
      queue_cydia_app(client, 'Open')
    end
    
    with_user_prompt(
        before: "Queueing BundleIDs", 
        after: "Done queuing BundleIDs.", 
        error: "Error: Please queue BundleIDs and return to the Cydia search page and press enter...",
        automated: automated) do
      queue_cydia_app(client, 'BundleIDs')
    end

    with_user_prompt(
        before: "Queueing Sudo", 
        after: "Done queuing Sudo.", 
        error: "Error: Please queue Sudo and return to the Cydia search page and press enter...",
        automated: automated) do
      queue_cydia_app(client, 'Sudo')
    end

    with_user_prompt(
        before: "Queueing Erica Utilities", 
        after: "Done queuing Erica Utilities.", 
        error: "Error: Please queue Erica Utilities and return to the Cydia search page and press enter...",
        automated: automated) do
      modify_cydia_app(client, 'Erica Utilities')
    end
    
    with_user_prompt(
        before: "Queueing Core Utilities", 
        after: "Done queuing Core Utilities.", 
        error: "Error: Please queue Core Utilities and return to the Cydia search page and press enter...",
        automated: automated) do
      queue_cydia_app(client, 'Core Utilities')
    end

    with_user_prompt(
        before: "Queueing Gawk", 
        after: "Done queuing Gawk.", 
        error: "Error: Please queue Gawk and return to the Cydia search page and press enter...",
        automated: automated) do
      queue_cydia_app(client, 'Gawk')
    end

    with_user_prompt(
        before: "Queueing Vi IMproved", 
        after: "Done queuing Vi IMproved.", 
        error: "Error: Please queue Vi IMproved and return to the Cydia search page and press enter...",
        automated: automated) do
      queue_cydia_app(client, 'Vi IMproved', return_to_search: false)
    end

    with_user_prompt(
        before: "Installing Queue", 
        after: "Done Installing Queue.", 
        error: "Error: Please manually install, restart springboard and press enter...",
        automated: automated) do
      client.tap_element(label: 'Installed')
      client.tap_element(label: 'Queue')
      client.tap_element(label: 'Confirm')
    end

    puts "Done."
  end

  def run_iclean(automated: true)
    client = WebDriverAgentClient.new(@ip, @port)
    client.start_remote(@device_id, @web_driver_agent_path)
    client.start_session('org.altervista.exilecom.icleaner')

    with_user_prompt(
        before: "Deleting dictionaries", 
        after: "Done deleting dictionaries.", 
        error: "Error: Please manually remove all non Apple Dictionaires and then push enter...",
        automated: automated) do
      client.tap_element(label: 'Advanced')
      client.tap_element(label: 'Definition dictionaries', element_type: "StaticText")
      sleep 3

      client.tap_element(label: 'Edit')

      dictionary_element_ids = client.elements_by_class_chain('XCUIElementTypeWindow/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeTable/XCUIElementTypeCell')
      
      dictionary_element_ids.each do |dictionary_element_id|
        children = client.get_element_children(dictionary_element_id)
        label_id = children[2]
        delete_label_id = children[1]
        if client.get_element_attribute(label_id, attribute: 'name') != "Apple Dictionary"
          client.tap_element(id: delete_label_id)
          client.tap_element(label: 'Delete')
        end
      end

      client.tap_element(label: 'Done')
      client.tap_element(label: 'Back')
    end

    with_user_prompt(
        before: "Deleting languages", 
        after: "Done deleting languages.", 
        error: "Error: Please manually remove languages and then push enter...",
        automated: automated) do
      client.tap_element(label: 'Languages', element_type: "StaticText", element_index: 1)
      client.tap_element(label: 'Languages to remove', element_type: "StaticText")
      client.tap_element(label: 'All')
      client.tap_element(label: 'Back')
      client.tap_element(label: 'Languages', element_type: "StaticText", element_index: 1)
      client.tap_element(label: 'Clean')

      sleep 30

      begin
        client.tap_element(label: 'Close Advertisement', wait_time: 120)
      rescue WebDriverAgentClient::WebDriverAgentError => e
        # Sometimes the ad doesn't label it's close ad button,
        # Try tapping the first one that shows up.
        button_ids = client.elements_by_class_name('Button')
        
        if button_ids.size > 0
          client.tap_element(id: button_ids[0]) 
        else
          puts 'No ad detected.. assuming none showed up.'
        end
      end
      
      client.tap_element(label: 'Ok', wait_time: 60)
    end

    with_user_prompt(
        before: "Deleting keyboards", 
        after: "Done deleting keyboards.", 
        error: "Error: Please manually remove keyboards and then push enter...",
        automated: automated) do
      client.tap_element(label:'Keyboards', element_type: "StaticText")
      client.tap_element(label:'Clean')

      sleep 10
      
      begin
        client.tap_element(label:'Close Advertisement', wait_time: 30)
      rescue WebDriverAgentClient::WebDriverAgentError => e
        button_ids = client.elements_by_class_name('Button')
        
        if button_ids.size > 0
          client.tap_element(id: button_ids[0]) 
        else
          puts 'No ad detected.. assuming none showed up.'
        end
      end

      client.tap_element(label:'Ok', wait_time: 120)
    end

    with_user_prompt(
        before: "Performing general clean", 
        after: "Done perfoming general clean.", 
        error: "Error: Please manually remove perform general clean push enter...",
        automated: automated) do
      client.tap_element(label: 'Clean')
      client.tap_element(label: 'Clean')
      begin
        client.tap_element(label: 'Close Advertisement', wait_time: 30)
      rescue WebDriverAgentClient::WebDriverAgentError => e
        button_ids = client.elements_by_class_name('Button')
        
        if button_ids.size > 0
          client.tap_element(id: button_ids[0]) 
        else
          puts 'No ad detected.. assuming none showed up.'
        end
      end
    end

    puts "Done."
  end

  def setup_settings(automated: true)
    client = WebDriverAgentClient.new(@ip, @port)
    client.start_remote(@device_id, @web_driver_agent_path)
    client.start_session('com.apple.Preferences')
    
    with_user_prompt(
        before: "Turning off passcodes.", 
        after: "Done turning off passcodes.", 
        error: "Error: manually turn off passcode and navigate back to settings home...",
        automated: automated) do
      client.scroll_to_element(label: 'Touch ID & Passcode')
      client.tap_element(label: 'Touch ID & Passcode', element_type: 'StaticText')
      begin
        client.tap_element(label: 'Turn Passcode Off', element_type: 'StaticText')
      rescue WebDriverAgentClient::WebDriverAgentError => e
        puts "Unable to find the turn passcode off button, assuming passcodes already disabled."
      end
      client.tap_element(label: 'Settings')
    end

    with_user_prompt(
        before: "Setting display toggles.", 
        after: "Done settings display toggles.", 
        error: "Error: manually set display toggles and navigate back to settings home...",
        automated: automated) do
      client.scroll_to_element(label: 'Display & Brightness')
      client.tap_element(label: 'Display & Brightness', element_type: 'StaticText')
      client.tap_element(label: 'Auto-Brightness', element_type: 'Switch') if client.is_switch_on?(switch_label: 'Auto-Brightness')
      client.tap_element(label: 'Auto-Lock', element_type: 'StaticText')
      client.tap_element(label: 'Never', element_type: 'StaticText')
      begin
        client.tap_element(label: 'Display & Brightness')
      rescue WebDriverAgentClient::WebDriverAgentError => e
        # On iPhone 5s the button is just "Back"
        client.tap_element(label: 'Back')
      end
      client.tap_element(label: 'Settings')
    end

    with_user_prompt(
        before: "Disabling bluetooth.", 
        after: "Done disabling bluetooth.", 
        error: "Error: munually disable bluetooth and navigate back to settings home...",
        automated: automated) do
      client.scroll_to_element(label: 'Bluetooth')
      client.tap_element(label: 'Bluetooth', element_type: 'StaticText')
      client.tap_element(label: 'Bluetooth', element_type: 'Switch') if client.is_switch_on?(switch_label: 'Bluetooth')
      client.tap_element(label: 'Settings')
    end

    with_user_prompt(
        before: "Disabling fitness settings.", 
        after: "Done disabling fitness settings.", 
        error: "Error: munually disable fitness settings and navigate back to settings home...",
        automated: automated) do
      client.scroll_to_element(label: 'Privacy')
      client.tap_element(label: 'Privacy', element_type: 'StaticText')
      client.scroll_to_element(label: 'Motion & Fitness')
      client.tap_element(label: 'Motion & Fitness', element_type: 'StaticText')
      if client.element_exists?('Switch', 'Fitness Tracking') and client.is_switch_on?(switch_label: 'Fitness Tracking')
        client.tap_element(label: 'Fitness Tracking', element_type: 'Switch')
      end
      if client.element_exists?('Switch', 'Health') and client.is_switch_on?('Health')
        client.tap_element(label: 'Health', element_type: 'Switch')
      end
      client.tap_element(label: 'Privacy')
      client.tap_element(label: 'Settings')
    end

    with_user_prompt(
        before: "Disabling government alerts.", 
        after: "Done disabling government alerts.", 
        error: "Error: munually disable government alerts and navigate back to settings home...",
        automated: automated) do
      client.scroll_to_element(label: 'Notifications')
      client.tap_element(label: 'Notifications', element_type: 'StaticText')

      if client.element_exists?("StaticText", "AMBER Alerts")
        client.scroll_to_element(label: 'AMBER Alerts')
        client.tap_element(label: 'AMBER Alerts', element_type: 'Switch') if client.is_switch_on?(switch_label: 'AMBER Alerts')
      end

      if client.element_exists?("StaticText", "Emergency Alerts")
        client.scroll_to_element(label: 'Emergency Alerts')
        client.tap_element(label: 'Emergency Alerts', element_type: 'Switch') if client.is_switch_on?(switch_label: 'Emergency Alerts')
      end

      client.tap_element(label: 'Settings')
    end

    with_user_prompt(
        before: "Configuring app store.", 
        after: "Done configuring app store.", 
        error: "Error: munually configure app store...",
        automated: automated) do
      puts "Push enter once you've run the following command:\nIosDevice.setup_device(serial_number: x, ip: x, ios_version: x, model_name: x, description: x, skip_us_account: false)\nYou will be prompted for the account email and password in the next steps..."
      gets.chomp
      puts "Account email: "
      email = gets.chomp
      puts "Account password: "
      password = gets.chomp

      client.scroll_to_element(label: 'iTunes & App Store')
      client.tap_element(label: 'iTunes & App Store', element_type: 'StaticText')

      client.tap_element(label: 'Sign In', element_type: 'StaticText')
      client.type_into_field(email, value: 'Apple ID', element_type: 'TextField')
      client.type_into_field(password, value: 'Password', element_type: 'SecureTextField')
      client.tap_element(label: 'Sign In')

      sleep 5

      client.tap_element(label: 'Password Settings', element_type: 'StaticText')
      client.tap_element(label: 'Require After 15 Minutes', element_type: 'StaticText')

      sleep 1

      client.tap_element(label: 'Require Password', element_type: 'Switch') if client.is_switch_on?(switch_label: 'Require Password')
      
      begin
        client.tap_element(label: 'iTunes & App Stores')
      rescue WebDriverAgentClient::WebDriverAgentError => e
        # On iPhone 5s the button is just "Back"
        client.tap_element(label: 'Back')
      end

      switch_ids = client.elements_by_class_name('Switch')
      switch_ids.each do |switch_id|
        client.tap_element(id: switch_id) if client.is_switch_on?(id: switch_id)
      end
    end

    puts "Done."
  end

  #### Private helper methods

  def with_user_prompt(before: "", after: "", error: "", automated: true)
    unless automated
      puts before + " (Push Enter To Continue, or 'skip' to skip step...)"
      before_response = gets.chomp
      
      if before_response == 'skip'
        return
      end
    end

    begin
      yield
      puts after
    rescue RuntimeError => e
      puts error
      error_response = gets.chomp
    end
  end

  def modify_cydia_app(client, app_name, return_to_search: true, expected_version: nil)
    client.tap_element(label: 'Search')
    client.type_into_field(app_name, label: 'Package Names & Descriptions')
    client.tap_element(label: app_name, element_type: 'Cell')
    
    if expected_version
      raise RuntimeError, "Expected version #{expected_version} of #{app_name} not found." if not client.element_exists?('StaticText', expected_version) 
    end
    
    client.tap_element(label: 'Modify')
    client.tap_element(label: 'Install')
    client.tap_element(label: 'Continue Queuing', element_type: "Link")
    client.tap_element(label: 'Search') if return_to_search
  end

  def queue_cydia_app(client, app_name, return_to_search: true)
    client.tap_element(label: 'Search')
    client.type_into_field(app_name, label: 'Package Names & Descriptions')
    client.tap_element(label: app_name, element_type: "Cell")
    client.tap_element(label: 'Install')
    client.tap_element(label: 'Continue Queuing', element_type: "Link")
    client.tap_element(label: 'Search') if return_to_search
  end

end