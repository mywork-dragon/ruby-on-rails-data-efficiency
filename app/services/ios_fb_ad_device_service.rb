class IosFbAdDeviceService

  DEVICE_USERNAME = 'root'
  DEVICE_PASSWORD = 'padmemyboo'
  MAX_SCROLL_ITEMS = 50
  MAX_COMMAND_ATTEMPTS = 2
  IMAGE_FOLDER_PATH = File.join('/var', 'mobile', 'Media', 'DCIM', '100APPLE')
  SCRIPTS_PATH = File.join(Rails.root, 'server', 'ios_fb_scripts')
  SCRIPTS_PREFIX = SCRIPTS_PATH.split('/').last

  APPS_INFO_KEY = {
      facebook: {
        name: 'Facebook',
        bundle_id: 'com.facebook.Facebook'
      },
      photos: {
        name: 'MobileSlideShow',
        bundle_id: 'com.apple.mobileslideshow'
      },
      springboard: {
        name: 'SpringBoard',
        bundle_id: nil
      },
      app_store: {
        name: 'AppStore',
        bundle_id: 'com.apple.AppStore'
      }
  }

  # Error types
  class CriticalDeviceError < StandardError
    attr_reader :ios_device_id
    def initialize(msg, ios_device_id)
      @ios_device_id = ios_device_id
      super(msg)
    end
  end

  def initialize(ios_fb_ad_job_id, device, fb_account, bid: nil)
    @ssh = nil
    @device = device
    @fb_account = fb_account
    @ios_fb_ad_job_id = ios_fb_ad_job_id
    @has_switched = false
    @bid = bid
    @results = []
  end

  def start_scrape
    connect

    scrape
    # teardown

  rescue => e
    store_exception(e)
    raise e if e.class == CriticalDeviceError
  ensure
    disconnect
  end

  # For cleaning the device
  def clean
    connect

    teardown

  rescue => e
    store_exception(e)
    raise e if e.class == CriticalDeviceError
  ensure
    disconnect
  end

  # restart: flag to indicate whether to completely overwrite ssh connection
  def connect(restart: false)
    disconnect unless restart
    puts "connecting"
    @ssh = Net::SSH.start(@device.ip, DEVICE_USERNAME, :password => DEVICE_PASSWORD)
  end

  def disconnect
    return if @ssh.nil? || @ssh.closed?
    puts "closing"
    @ssh.close
  end

  def cycle_account
    Net::SSH.start(@device.ip, DEVICE_USERNAME, :password => DEVICE_PASSWORD) do |ssh|
      setup
      log_debug "Setup done"
      open_fb
      log_debug "Opened fb"
      log_in
      log_debug "Logged in"
      sleep 5
      log_out
      log_debug "Logged out"
    end
  end

  def scrape

    setup

    close_applications # ensure starting from scratch

    open_fb

    log_in if false && Rails.env.production?

    log_debug "Sleeping to let DOM load"
    sleep 5

    scroll

    store_results

    log_out if false && Rails.env.production?

    teardown

    @results
  rescue => e

    log_debug "Rescuing Exception"

    store_exception(e)

    store_results

    raise e if e.class == CriticalDeviceError

    log_out if false && Rails.env.production? && is_logged_in?

    teardown

    @results
  end

  def store_results
    log_debug "Storing Results"
    @results.each do |entry|
      next if entry.nil? || entry[:stored_success]
      begin
        ios_fb_ad = save_entry(entry)
        entry[:stored_success] = true
        trigger_processing(ios_fb_ad)
      rescue => e
        store_exception(e)
      end
    end
  end

  def save_entry(entry)
    row = {}

    # Store the image columns
    row[:ad_image] = File.open(entry[:ad_image_path]) if Rails.env.production?
    row[:ad_info_image] = File.open(entry[:ad_info_image_path]) if Rails.env.production?

    entry_columns = [
      :link_contents,
      :ad_info_html,
      :feed_index,
      :carousel
    ]

    entry_columns.each do |col|
      row[col] = entry[col]
    end

    # metadata
    row[:ios_fb_ad_job_id] = @ios_fb_ad_job_id
    row[:fb_account_id] = @fb_account.id
    row[:ios_device_id] = @device.id

    row[:status] = :preprocessed

    IosFbAd.create!(row)
  end

  def trigger_processing(ios_fb_ad)
    return unless Rails.env.production?

    if @bid
      begin
        batch = Sidekiq::Batch.new(@bid)
        batch.jobs do
          IosFbProcessingWorker.perform_async(ios_fb_ad.id)
        end
      rescue Sidekiq::Batch::NoSuchBatch => e
        store_exception(e)
        IosFbProcessingWorker.perform_async(ios_fb_ad.id)
      end
    else
      IosFbProcessingWorker.perform_async(ios_fb_ad.id)
    end

  end

  # this function cannot fail
  def store_exception(error)
    IosFbAdException.create!({
      ios_fb_ad_job_id: @ios_fb_ad_job_id,
      fb_account_id: @fb_account.id,
      ios_device_id: @device.id,
      error: error.message,
      backtrace: error.backtrace
    })
  end

  def remote_exec(command)
    resp, attempt = nil, 0

    while attempt < MAX_COMMAND_ATTEMPTS
      attempt += 1

      begin
        resp = @ssh.exec! command
      rescue Net::SSH::Disconnect => e
        resp = e
      rescue IOError => e
        resp = e
      rescue Errno::ECONNRESET => e
        resp = e
      rescue => e
        log_debug "Uncaught Error type: #{e.class} : #{e.message}"
      end

      return nil unless resp

      if resp.class == Net::SSH::Disconnect || resp.class == Errno::ECONNRESET
        log_debug "#{resp.class}: restarting connection"
        connect(restart: true)
      elsif resp.class == IOError
        log_debug "reconnecting"
        connect(restart: true)
      elsif resp.match(/ST Error:/)
      else
        return resp
      end

      log_debug "Retrying command after attempt #{attempt}. Command response: #{resp}"
    end

    raise CriticalDeviceError.new("Failed retry ssh commands with response: #{resp}", @device.id)
  end

  def run_command(command, description, expected_output = nil)
    # add additional check to ensure cycript command doesn't hang indefinitely
    is_cycript = /cycript -p (\w+)/.match(command)
    
    if is_cycript
      app_count = remote_exec "ps aux | grep #{is_cycript[1]} | grep -v grep | wc -l"
      raise "Running cycript on app #{is_cycript[1]} but app is not running or crashed" if app_count.include?('0')
    end

    resp = remote_exec command
    if expected_output != nil && resp.chomp != expected_output
      raise "Expected output #{expected_output}. Received #{resp.chomp}"
    end

    resp
  rescue CriticalDeviceError => e
    raise e
  rescue => error
    raise "Error during #{description} with command: #{command}. Message: #{error.message}"
  end

  def log_debug(str)
    prefix = "acct#{@fb_account.id},dev#{@device.id}: "
    puts prefix + str
  end

  def setup
    # install cycript scripts
    log_debug "Installing fb scripts"
    `/usr/local/bin/sshpass -p #{DEVICE_PASSWORD} scp -r #{SCRIPTS_PATH} #{DEVICE_USERNAME}@#{@device.ip}:~`
    log_debug "Done installing"
  end

  def open_fb
    log_debug "Opening FB"
    run_command('open com.facebook.Facebook', 'Open the facebook app')
    sleep 1.5
    run_file('Facebook', 'fb_utilities.cy')
    sleep 1.5
  end

  def get_feed_info
    info = JSON.parse(run_command("cycript -p Facebook #{File.join(SCRIPTS_PREFIX, 'find_items.cy')}", 'Get information about the available feed').chomp)

    section = info['section']
    items_count = info['itemsCount']

    log_debug "Found #{items_count} items in section #{section}"

    {
      section: section,
      items_count: items_count
    }
  end

  def refresh_item(index)
    2.times do |n|
      refresh_filename = "#{index}_refresh.cy"
      resp = run_file('Facebook', refresh_filename)
      sleep 0.5
    end
  end

  def scroll_to_item(index, top: true)
    scroll_filename = top ? "#{index}_scroll.cy" : "#{index}_bottom_scroll.cy"
    run_command("cycript -p Facebook #{File.join(SCRIPTS_PREFIX, scroll_filename)}", "Scroll to item #{index}")
  end

  def check_item(index)
    check_filename = "#{index}_check.cy"
    resp = run_command("cycript -p Facebook #{File.join(SCRIPTS_PREFIX, check_filename)}", "Check item #{index}")
  end

  def scroll
    item_index = 0
    # start with dummy information so that scripts are generated automatically
    info = {
      items_count: 0,
      section: -1
    }

    while item_index < MAX_SCROLL_ITEMS
      if item_index >= info[:items_count]
        # need to get more items
        refresh_feed_items(info[:items_count])
        info = create_section_scripts
      end

      scroll_to_item(item_index)
      log_debug "Scrolled to item #{item_index}"

      refresh_item(item_index) if @has_switched

      resp = check_item(item_index)
      log_debug "Checked item #{item_index}. Response: #{resp}"

      if command_success?(resp)
        # because of weird cell states, validate
        refresh_item(item_index)
        resp = check_item(item_index)
        log_debug "Checked item #{item_index}. Response: #{resp}"
      end

      analyze_item(item_index, info[:section]) if command_success?(resp)
      item_index += 1
    end

    log_debug "Finished scrolling through #{item_index} items"
  end

  # function assumes you're at the bottom of the available items in the feed
  def refresh_feed_items(prior_count)

    scroll = {
      start: {
        x: 50,
        y: 500
      },
      finish: {
        x: 50,
        y: 200
      }
    }

    scroll_screen(start: scroll[:start], finish: scroll[:finish])
    sleep 2 # let apple load the feed
    scroll_screen(start: scroll[:start], finish: scroll[:finish])
    sleep 2

    after = get_feed_info

    raise "Could not generate more items in the feed" unless prior_count < after[:items_count]

    after
  end

  def create_section_scripts

    info = get_feed_info

    run_command("cd #{SCRIPTS_PREFIX} && ./scroll_generator.sh #{info[:section]} #{info[:items_count]}" , 'Create scripts for each available section in the news feed')

    log_debug "Created scripts"
    info
  end

  def press_screen(x:, y:, orientation: 1)
    run_command("stouch touch #{x} #{y} #{orientation}", "Touch screen in orientation #{orientation} at location #{x}, #{y}")
  end

  def scroll_screen(start:, finish:, duration: 0.5)
    run_command("stouch swipe #{start[:x]} #{start[:y]} #{finish[:x]} #{finish[:y]} #{duration}", "Scroll screen from #{start[:x]},#{start[:y]} to #{finish[:x]},#{finish[:y]}")
  end

  def swipe_left
    scroll_screen({x: 200, y: 200, x: 400, y: 400, duration: 0.2})
  end


  def analyze_item(index, section)
    run_command("cd #{SCRIPTS_PREFIX} && ./template_button_scripts.sh #{section} #{index}", 'Template the button clicking scripts')

    log_debug "checking if carousel"
    resp = run_file('Facebook', "determine_ad_carousel_#{section}_#{index}.cy")

    if command_success?(resp)
      log_debug "Running carousel logic"
      count = resp.split(':').last.strip.to_i
      if count <= 0
        if @has_switched # sometimes there is a screwy state if app switching
          log_debug "Succeeded but found a section with 0 items. Moving on"
          return  
        else
          raise "Unexpected number of ads #{count} from response #{resp}" 
        end
      end

      run_command("cd #{SCRIPTS_PREFIX} && ./generate_ad_swipes.sh #{section} #{index} #{count}", 'Template the ad swiping scripts')

      count.times do |n|
        log_debug "Trying Ad #{n} in carousel"
        run_and_validate_success('Facebook', "#{n}_ad_swipe.cy")
        sleep 1
        refresh_item(index)
        results_info = analyze_ad(index, section)
        next unless results_info
        results_info[:carousel] = true
        @results.push(results_info)
      end
    else
      log_debug "Running single ad logic"
      results_info = analyze_ad(index, section)
      if results_info
        results_info[:carousel] = false
        @results.push(results_info)
      end
    end

  end

  def analyze_ad(index, section)
    results_info = {}

    # Take the screenshot before leaving FB
    results_info.merge!(take_ad_screenshot(section, index))

    # Now actually click the ad
    success = click_ad(index, section)

    unless success
      log_debug "Unable to click the ad button. May be due to fauly view from app switching"
      return
    end
    @has_switched = true


    link_contents = get_link

    log_debug "Got contents: #{link_contents}"

    press_screen(x: 5, y: 5) # press the return to Facebook button (iOS 9 only)
    sleep 1 # let fb load
    run_command("killall AppStore", 'kill the AppStore')

    # Now get the ad information screenshot
    results_info.merge!(take_ad_info_screenshot(section, index))
    results_info[:link_contents] = link_contents
    results_info[:feed_index] = index
    results_info
  end

  # returns true if clicked ad, false if unable (gracefully)
  def click_ad(index, section)
    # template the file
    filename = File.join(SCRIPTS_PREFIX, "select_item_#{section}_#{index}.cy")

    scroll_to_item(index, top: false)
    # run_command("cat #{infile} | sed -e s/\\\$1/#{index}/ -e s/\\\$0/#{section}/ > #{outfile}", 'Template the click ad script')

    button_attempts_without_failure = 2
    attempts = 0
    success = false
    resp = nil

    log_debug "Trying to press button"

    while attempts < button_attempts_without_failure && !success

      log_debug "Attempt #{attempts}"
      resp = run_command("cycript -p Facebook #{filename}", 'run the click ad file')

      log_debug "Button press response: #{resp.chomp}"

      if resp.match(/Error:/i)
        log_debug "Failed to press button: #{resp.chomp}"
        return false
      end

      sleep 4

      verify = run_command('ps aux | grep AppStore | grep -v grep | wc -l', 'See if AppStore is running')
      success = true if verify.include?('1')
      attempts += 1
    end

    unless success
      if @has_switched
        return false # sometimes after switching, cells are in weird state
      else
        raise "AppStore did not open after clicking ad"
      end
    end

    log_debug "Finished pressing button"

    # Bind the utilities to the app store
    run_command("cycript -p AppStore #{File.join(SCRIPTS_PREFIX, 'fb_utilities.cy')}", 'Bind utilities to the AppStore')

    true
  end

  def get_link
    # click the share button at the top

    log_debug "Trying to press Share button"
    i = 0
    max_attempts = 3
    pressed = false
    resp = nil

    while i < max_attempts && !pressed
      log_debug "Attempt #{i}"
      resp = run_file('AppStore', 'click_share.cy')
      pressed = true if command_success?(resp)
      i += 1
      sleep 2
    end

    raise resp unless pressed

    log_debug "Pressed share"
    sleep 1 # let the menu option show

    # select the copy link button
    press_coordinates_from_file('get_copy_link_coordinates.cy', 'AppStore')
    sleep 1 # let menu board go away

    # resp = run_command("cycript -p AppStore #{File.join(SCRIPTS_PREFIX, 'select_copy_link.cy')}", 'Press the copy link button')

    # raise resp unless resp.match(/Pressed/i)
    # log_debug "Pressed copy"

    # Get the pasteboard contents
    resp = run_command("cycript -p AppStore #{File.join(SCRIPTS_PREFIX, 'get_clipboard_contents.cy')}", 'Get the clipboard contents').chomp

    raise "Did not get clipboard contents: #{resp}" if resp.nil? || resp.match(/Error:/i)

    resp
  end

  # takes the screenshots, moves to local computer with unique id, returns a hash with information
  def take_ad_screenshot(section, index)

    scroll_to_item(index)

    resp = run_command("cycript -p Facebook #{File.join(SCRIPTS_PREFIX, 'hide_tab_bar.cy')}", 'Hide the tab bar')

    raise resp unless command_success?(resp)

    log_debug "Hid Bar"

    outfile = take_screenshot('FB_CREATIVE')

    resp = run_command("cycript -p Facebook #{File.join(SCRIPTS_PREFIX, 'show_tab_bar.cy')}", 'Hide the tab bar')

    raise resp unless command_success?(resp)

    log_debug "Show Bar"
    {
      ad_image_path: outfile
    }
  end

  def take_ad_info_screenshot(section, index)

    log_debug "Taking ad info screenshot"
    scroll_to_item(index)

    run_and_validate_success('Facebook', "press_ad_options_#{section}_#{index}.cy")
    sleep 0.5

    run_and_validate_success('Facebook', 'select_ad_explanation.cy')
    sleep 4 # takes a while to load web view

    run_and_validate_success('Facebook', 'validate_ad_info_visible.cy')

    outfile = take_screenshot('FB_AD_INFO')
    html_content = run_file('Facebook', 'get_ad_info_html.cy')

    html_content = nil if known_command_error?(html_content)

    run_and_validate_success('Facebook', 'navigate_back_from_preferences.cy')
    sleep 1

    {
      ad_info_image_path: outfile,
      ad_info_html: html_content
    }
  end

  # takes screenshot, moves to local computer and returns the path
  def take_screenshot(image_prefix)
    resp = run_command("cycript -p SpringBoard #{File.join(SCRIPTS_PREFIX, 'take_screenshot.cy')}", 'Take the screenshot')
    sleep 2 # let the screenshot get stored

    raise resp unless command_success?(resp)

    image_path = run_command("./#{File.join(SCRIPTS_PREFIX, 'get_recent_image_path.sh')}", 'take screenshot').chomp

    raise "No image available" if image_path.nil?

    log_debug "Copying image"

    outfile = File.join('/tmp', "#{image_prefix}_#{@device.id}_#{image_path.split('/').last}")

    `/usr/local/bin/sshpass -p #{DEVICE_PASSWORD} scp #{DEVICE_USERNAME}@#{@device.ip}:#{image_path} #{outfile}`

    raise "Image failed to copy over" unless 

    # validate
    resp = `[ -f #{outfile} ] && echo 'exists' || echo 'dne'`.chomp
    raise "Failed to scp image file" unless resp.include?('exists')

    outfile
  end

  def log_in
    log_debug "Logging in user"

    raise "No FB Account" unless @fb_account.present?

    # Ensure no one is currently logged in

    log_debug "Ensuring no account is logged in"

    raise "An account is already logged in" if is_logged_in?

    # template the file
    infile = File.join(SCRIPTS_PREFIX, 'log_in.tmp.cy')
    outfile = File.join(SCRIPTS_PREFIX, 'log_in.cy')
    run_command("cat #{infile} | sed -e s/\\\$0/#{@fb_account.username}/ -e s/\\\$1/#{@fb_account.password}/ > #{outfile}", 'Templating log in file')

    # run it
    resp = run_command("cycript -p Facebook #{outfile}", 'Running log in file').chomp

    raise "Failed with message: #{resp}" unless resp.match(/Pressed/i)
    sleep 7 # Let the request get sent

    # verify
    log_debug "Verifying log in"

    raise "Failed to log in" unless is_logged_in?

    log_debug "Success!"
  end

  # logs out. Intelligently checks to ensure log out is necessary
  def log_out

    # ensure FB is open and logged in
    log_debug "Logging out"
    return unless is_logged_in?

    # Navigate through the log out sections
    navigate_files = %w(press_more.cy scroll_to_logout.cy press_logout.cy)
    navigate_files.each do |file|
      run_and_validate_success('Facebook', file)
      sleep 1.5 # let the view load
    end

    confirm_logout
    sleep 1.5

    raise "Failed to log out" if is_logged_in?
  end

  # checks if logged in and opens fb
  def is_logged_in?
    log_debug "Checking if logged in"
    open_fb
    sleep 2
    resp = run_file('Facebook', 'is_logged_in.cy')
    resp.match(/True/i)
  end

  def press_coordinates_from_file(filename, app, mini_swipe: false)
    coordinates = run_file(app, filename)

    coordinates_json = nil
    begin
      coordinates_json = JSON.parse(coordinates)
    rescue
      raise "Could not parse coordinates json with contents: #{coordinates}"
    end

    if mini_swipe
      scroll_screen(start: {x: coordinates_json['x'], y: coordinates_json['y']}, finish: {x: coordinates_json['x'] + 5, y: coordinates_json['y']}, duration: 0.1)
    else
      press_screen(x: coordinates_json['x'], y: coordinates_json['y'])
    end
  end

  def delete_screenshots
    log_debug "Deleting screenshots"
    image_count = run_command("find #{IMAGE_FOLDER_PATH} -mindepth 1 | wc -l", 'Get image count').chomp

    if image_count == '0'
      log_debug "No images to delete"
      return
    end

    log_debug "Attempting to delete #{image_count} images"

    log_debug "Opening Photos"
    open_app(:photos)
    sleep 1

    log_debug "Pressing Albums"

    run_and_validate_success('MobileSlideShow', 'press_albums.cy')
    sleep 0.25


    log_debug "Selecting Camera Roll"

    run_and_validate_success('MobileSlideShow', 'select_camera_roll.cy')
    sleep 0.25

    log_debug "Checking for Photos in Camera Roll available to delete"

    resp = run_file('MobileSlideShow', 'check_for_selectable_photos.cy')

    if command_success?(resp)
      log_debug "Found #{resp.split(':').last.strip} photos to delete"

      log_debug "Scrolling to top of Camera"

      run_and_validate_success('MobileSlideShow', 'scroll_to_top_of_photos.cy')
      sleep 0.25

      log_debug "Pressing Select Mode"

      # resp = run_command("cycript -p MobileSlideShow #{File.join(SCRIPTS_PREFIX, 'press_select_mode.cy')}", 'Select Camera Roll')
      # raise resp unless command_success?(resp)
      press_screen(x: 25, y: 25, orientation: 3) # cheating...it's in the upper right hand corner
      sleep 0.25

      "Getting available coordinates"
      resp = run_file('MobileSlideShow', 'get_photo_coordinates.cy')
      coordinates = nil
      begin
        coordinates = JSON.parse(resp.chomp)
      rescue
        raise "Could not parse coordinates list with contents #{resp}"
      end

      coordinates.each do |coordinate|
        x = coordinate['x']
        y = coordinate['y']
        log_debug "Trying to press (#{x}, #{y})"
        press_screen(x: x, y: y)
        sleep 0.1
      end


      log_debug "Pressing Trash"
      press_screen(x: 10, y: 10, orientation: 2) # cheating...we know it's in the bottom right corner
      sleep 0.25

      log_debug "Confirming Delete"
      confirm_photo_delete
      sleep 0.5 # let the photos move
    end

    log_debug "Return to Album Screen"
    press_screen(x: 25, y: 25) # cheating...upper left in nav
    sleep 1 # let the recently deleted album populate

    log_debug "Press Recently Deleted"
    resp = run_file('MobileSlideShow', 'select_recently_deleted.cy')
    sleep 1

    log_debug "Press Select"
    press_screen(x: 25, y: 25, orientation: 3) # cheating...upper right
    sleep 0.25

    log_debug "Press Delete All"
    press_screen(x:25, y: 25, orientation: 4) # cheating...lower left
    sleep 0.5 # wait for pop up to render

    log_debug "Confirming Permanent Delete"
    confirm_photo_delete
    sleep 1

    run_command('killall MobileSlideShow', 'Killing Photos app')
  end

  def confirm_photo_delete

    # verify_command = "cycript -p MobileSlideShow #{File.join(SCRIPTS_PREFIX, 'confirm_delete_coordinates.cy')}"

    # 2.times do |n|
    #   log_debug "Attempt #{n}"
    #   press_coordinates_from_file('confirm_delete_coordinates.cy', 'MobileSlideShow')
    #   sleep 0.25
    #   resp = run_command(verify_command, 'Check transition view dismissed')
    #   return if known_command_error?(resp) # Should error...cannot find coordinates
    # end

    # raise "Failed to confirm delete"

    confirm_submit_alert_action('MobileSlideShow', 'confirm_delete_coordinates.cy', 'confirm_delete_coordinates.cy')
  end

  def confirm_logout
    confirm_submit_alert_action('Facebook', 'get_confirm_logout_coordinates.cy', 'get_confirm_logout_coordinates.cy')
  end

  def confirm_submit_alert_action(app, coordinates_file, verify_file)
    2.times do |n|
      log_debug "Attempt #{n}"
      press_coordinates_from_file(coordinates_file, app, mini_swipe: true)
      sleep 2 # confirming an alert action normally triggers a large UI change 
      resp = run_file(app, verify_file)
      return if known_command_error?(resp) # Should error...cannot find coordinates
    end

    raise "Failed to confirm alert view from app #{app}"
    log_debug "Successfully confirmed alert action"
  end

  def known_command_error?(resp)
    resp.match(/Error:/)
  end
  def command_success?(resp)
    resp.match(/Success/)
  end

  def open_app(app)

    info = APPS_INFO_KEY[app]

    raise "#{app} is not recognized" if info.nil?

    run_command("killall #{info[:name]}", "Ensure #{info[:name]} is closed")
    sleep 1
    run_command("open #{info[:bundle_id]}", "Open the #{info[:name]} app")
    sleep 1
    run_command("cycript -p #{info[:name]} #{File.join(SCRIPTS_PREFIX, 'fb_utilities.cy')}", "Bind the utilities to #{info[:name]}")
  end

  def close_applications

    apps_count = get_open_apps_count
    log_debug "Closing #{apps_count} apps"

    open_apps_carousel
    sleep 2

    apps_count.times do |n|
      log_debug "Closing #{n}"
      scroll_screen(start: {x: 200, y: 200}, finish: {x: 400, y: 200}, duration: 0.2) # Swipe left
      sleep 0.25
      scroll_screen(start: {x: 100, y: 400}, finish: {x: 100, y: 200}, duration: 0.2) # Swipe up
      sleep 0.25
    end

    apps_count = get_open_apps_count
    log_debug "Apps remaining: #{apps_count}"
    log_debug "Ensuring primary ones closed"

    %i(facebook photos app_store).each do |app_key|
      ensure_closed(APPS_INFO_KEY[app_key][:name])
    end

    return_to_home_screen

    log_debug "Finished closing apps"

  end

  def ensure_closed(app_name)
    resp = run_command("ps aux | grep -v grep | grep #{app_name} | wc -l", "Check if app #{app_name} is still running")
    puts "#{app_name} is not closed" unless resp.include?('0')
  end

  def get_open_apps_count
    run_command("ps aux | grep -v grep | grep Application | grep -v private/var | wc -l", "Get current apps count").to_i
  end

  def open_apps_carousel
    return_to_home_screen
    sleep 0.5
    run_and_validate_success('SpringBoard', 'open_active_apps.cy')
  end
  
  def return_to_home_screen
    run_and_validate_success('SpringBoard', 'return_to_home.cy')
  end

  def teardown
    log_debug "Teardown"
    close_applications
    delete_screenshots
    
    # run_command('rm -rf ios_fb_scripts *.cy', 'Remove cycript scripts')
    run_command('rm -rf *.cy', 'Remove cycript scripts')
  end

  def run_and_validate_success(app, filename)
    resp = run_file(app, filename)
    raise resp unless command_success?(resp)
    resp
  end

  def run_file(app, filename)
    run_command("cycript -p #{app} #{File.join(SCRIPTS_PREFIX, filename)}", "Run file #{filename} on #{app}")
  end

end
