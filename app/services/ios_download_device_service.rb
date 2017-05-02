class IosDownloadDeviceService
  include IosDeviceUtilities

  UTIL_SRC = File.join(Rails.root, 'server', 'ios_download_scripts')
  UTIL_DEST = File.join('/var', 'root', 'ios_download_scripts')

  TEMP_DIRECTORY = '/tmp'

  home = `echo $HOME`.chomp
  DECRYPTED_FOLDER = "#{home}/decrypted_ios_apps"

  DISPLAY_STATUSES = {
    downloading: {
      commands: "updateDebugStatus(\"Waiting for download\", [UIColor yellowColor]);",
      filename: 'download_waiting.cy'
    },
    download_complete: {
      commands: "updateDebugStatus(\"Finished download\", [UIColor greenColor]);",
      filename: 'download_complete.cy'
    },
    start_decrypt: {
      commands: "updateDebugStatus(\"Running Decrypt\", [UIColor yellowColor]);",
      filename: 'start_decrypt.cy'
    },
    start_scp: {
      commands: "updateDebugStatus(\"SCP Binary\", [UIColor yellowColor]);",
      filename: 'start_scp.cy'
    },
    start_classdump: {
      commands: "updateDebugStatus(\"Running ClassDump\", [UIColor yellowColor]);",
      filename: 'start_classdump.cy'
    },
    start_strings: {
      commands: "updateDebugStatus(\"Running Strings\", [UIColor yellowColor]);",
      filename: 'start_strings.cy'
    },
    finish_processing: {
      commands: "updateDebugStatus(\"Finished Processing Decrypted File\", [UIColor greenColor]);",
      filename: 'finish_processing.cy'
    },
    building_tar: {
      commands: "updateDebugStatus(\"Building Tar file\", [UIColor yellowColor]);",
      filename: 'building_tar.cy'
    },
    copying_tar: {
      commands: "updateDebugStatus(\"SCP Tar\", [UIColor yellowColor]);",
      filename: 'copying_tar.cy'
    },
    complete_packaging: {
      commands: "updateDebugStatus(\"Finished summary\", [UIColor greenColor]);",
      filename: 'complete_packaging.cy'
    },
    s3_upload: {
      commands: "updateDebugStatus(\"Starting s3 upload\", [UIColor yellowColor]);",
      filename: 's3_upload.cy'
    },
    begin_teardown: {
      commands: "updateDebugStatus(\"Beginning uninstall\", [UIColor greenColor]);",
      filename: 'begin_teardown.cy'
    }
  }

  class SignInFailed < RuntimeError; end
  class DontRequirePasswordFailed < RuntimeError; end
  class IMessageOnlyApp < RuntimeError; end
  
  class NoJbApp; end

  def initialize(device, apple_account:, account_changed_lambda: nil)
    @device = device
    @bundle_info = nil
    @decrypted_path = nil
    @apple_account = apple_account
    @account_changed_lambda = account_changed_lambda
    configure(UTIL_SRC, UTIL_DEST)
  end

  def apps_install_path
    if @device.ios_version_fmt >= IosDevice.ios_version_to_fmt_version('9.3.3')
      '/var/containers/Bundle/Application/'
    else
      '/var/mobile/Containers/Bundle/Application/'
    end
  end

  def run(app_identifier, lookup_content, purpose, classdump_id)
    @app_identifier = app_identifier
    @lookup_content = lookup_content
    @classdump_id = classdump_id
    @purpose = purpose
    @app_info = nil
    initialize_result
    execute_download_and_scrape { |res| yield(res) } # pass block through method
    clean_up_result
    @result
  end

  def initialize_result
    @result = { success: false }
    @result.merge!(account_success: false) if @account_changed_lambda
    @result.merge!(
      install_success: false,
      dump_success: false,
      teardown_success: false,
      teardown_retry: false,
      timestamp: Time.now,
    )
  end

  def install_display_statuses
    DISPLAY_STATUSES.keys.each do |key|
      command = DISPLAY_STATUSES[key][:commands]
      filename = DISPLAY_STATUSES[key][:filename]
      template_file(filename, command)
    end
  end

  def clean_up_result
    # make times into durations (except timestamp). Array order matters
    timestops = [:teardown_time, :dump_time, :install_time, :timestamp]
    timestops[0..-2].each_with_index do |value, index|
      @result[timestops[index]] = @result[timestops[index]] - @result[timestops[index+1]] if (@result[timestops[index]] && @result[timestops[index+1]])
    end

    @result[:duration] = Time.now - @result[:timestamp]
    # last time, update status
    if @result[:install_success] && @result[:dump_success] && @result[:teardown_success]
      @result[:success] = true
    end
  end

  def execute_download_and_scrape
    connect
    setup_device_scripts
    install_display_statuses
    change_account if @account_changed_lambda
    install
    @result[:install_time] = Time.now
    @result[:install_success] = true

    yield(@result) if block_given?

    @result.merge!(build_summary)
    @result[:dump_time] = Time.now
    @result[:dump_success] = true

    print_display_status(:s3_upload)
    upload_decrypted_execs
    yield(@result) if block_given?


    teardown
    @result[:teardown_success] = true
    @result[:teardown_time] = Time.now
    @result[:success] = true
  rescue => error
    log_debug 'An error occurred. Aborting'
    @result[:error] = error.message
    @result[:trace] = error.backtrace
    @result[:error_code] = :ssh_failure if error.class == Errno::ETIMEDOUT
    if error.cause
      @result[:error_root] = error.cause.message
      @result[:trace] = error.cause.backtrace
    end
    ensure_teardown if @result[:install_success] && !@result[:teardown_success]
  ensure
    disconnect
  end

  def ensure_teardown
    @result[:teardown_retry] = true
    connect(restart: true) # could have errored because disconnected
    teardown
    @result[:teardown_success] = true
  rescue => teardown_error
    @result[:error_teardown] = teardown_error.message
    @result[:error_teardown_trace] = teardown_error.backtrace
  end

  def open_app_in_app_store
    run_file(:springboard, 'open_app_in_app_store.cy')
    sleep(1)
    load_common_utilities(:app_store)
  end

  def jb_ipa_path
    return @jb_ipa_path if @jb_ipa_path
    resp = run_command(
      "find #{apps_install_path} -maxdepth 2 -name 'NvwaStone.app' -or -name 'PPJailbreakCarrier.app' -or -name 'yalu102.app'",
      'find jb app'
    )
    @jb_ipa_path = resp.present? ? resp.chomp : NoJbApp
  end

  def current_installed_apps
    apps = run_command("ls #{apps_install_path}", 'get ipa bundles')
    if apps == nil
      []
    else
      jb = jb_ipa_path
      jb_bundle = jb == NoJbApp ? [] : [jb.split('/').last(2).first]
      apps.chomp.split - jb_bundle
    end
  end

  # execute any of the dump status commands against the AppStore
  def print_display_status(status)
    open_app(:app_store) unless is_app_running?(:app_store)
    raise "Status #{status} is not valid" if DISPLAY_STATUSES[status].nil?
    run_file(:app_store, DISPLAY_STATUSES[status][:filename])
  end

  def press_download!
    success = false
    10.times do |n|
      open_app_in_app_store unless is_app_running?(:app_store)
      log_debug 'Waiting 3s...'
      sleep(3)
      log_debug "Try #{n}"
      ensure_not_imessage_only_app!
      ret = run_file(:app_store, 'download_app.cy')
      if ret.nil?
        log_debug 'Did not start downloading'
      elsif ret.include?('Downloading')
        log_debug 'Download started'
        success = true
        break
      elsif ret.include?('Installed')
        log_debug 'Already installed'
        success = true
        break
      elsif ret.include?('Pressed button')
        log_debug 'Pressed button'
      else
        log_debug 'Did not start downloading'
      end
    end

    raise 'Unable to initiate download' unless success
  end

  def install_open_app_scripts
    bundle_id = @lookup_content['bundleId']
    raise "no bundle id available" if bundle_id.nil?
    content = File.open(File.join(UTIL_SRC, 'verify_install.cy'), 'rb') { |f| f.read } % [bundle_id]
    template_file(
      'verify_install.cy',
      content
    )
  end

  def ensure_downloaded!
    success = false
    install_open_app_scripts
    wait_time = @purpose == :mass ? 120 : 60 # 10 vs 5 min
    wait_time.times do |n|
      open_app_in_app_store unless is_app_running?(:app_store)
      log_debug 'Waiting 5s...'
      sleep(5)
      log_debug "Try #{n}"
      bundle_check = run_file(:springboard, 'verify_install.cy')
      if bundle_check && bundle_check.chomp.include?('Completed')
        log_debug 'Finished install'
        print_display_status(:download_complete)
        success = true
        break
      else
        print_display_status(:downloading)
      end
      puts ''
    end
    raise 'App is not installed' unless success
  end

  def install
    log_debug 'install'
    kill_app(:app_store)
    open_url = "itms-apps://itunes.apple.com/app/id#{@app_identifier}?mt=8"
    template_file(
      'open_app_in_app_store.cy',
      "[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@\"#{open_url}\"]]"
    )
    open_app_in_app_store

    prior_apps = current_installed_apps
    log_debug "prior_apps: #{prior_apps.join(' ')}"
    press_download!
    ensure_downloaded!

    apps_after = current_installed_apps
    raise 'No applications installed, so download failed' if apps_after.empty?
    log_debug "apps after: #{apps_after.join(' ')}"

    new_app_folder = if apps_after == prior_apps
                       raise UnexpectedCondition unless apps_after.count == 1
                       apps_after.first
                     else
                       apps_after.select { |id| !prior_apps.include?(id) }.first
                     end
    @app_info = get_app_name_and_path(new_app_folder)
  end

  def ensure_not_imessage_only_app!
    return if @device.ios_version_fmt < IosDevice.ios_version_to_fmt_version('10.0') # only available on iOS 10+
    res = run_file(:app_store, 'check_imessage_only.cy')
    raise IMessageOnlyApp if command_success?(res)
  end

  def get_app_name_and_path(new_app_folder = nil)
    if !new_app_folder
      # this assumes app is most recently installed (not always true)
      new_app_folder = run_command("ls -1t #{apps_install_path}", 'list all installed bundles').chomp.split("\n").first.chomp
    end

    new_path = File.join(apps_install_path, new_app_folder)
    app_name = run_command(
      "ls -1 #{new_path} | grep \".*\.app\"",
      'get app directory'
    ).chomp.split("\n").first.chomp.gsub('.app', '')

    return {
      name: app_name,
      path: Shellwords.escape(new_path)
    }
  end

  def ensure_signed_in
    success = false
    4.times do
      resp = run_file(:settings, 'check_sign_in.cy')
      if command_success?(resp)
        success = true
        break
      end
      sleep 4
    end
    raise SignInFailed unless success
  end

  def change_account

    log_debug "change_account"
    apple_id = @apple_account.email
    password = @apple_account.password

    # template the scripts
    run_command("pushd #{UTIL_DEST} && ./template_account_scripts.sh #{apple_id} #{password}", 'Template the account scripts')

    # open app (automatically binds common utilities)
    open_app(:settings, kill_existing: true)

    log_debug 'select_app_and_itunes_stores_script'
    run_and_validate_success(:settings, 'select_app_and_itunes_stores.cy')
    sleep(2)

    log_debug 'sign_out_script'
    run_and_validate_success(:settings, 'sign_out.cy')
    sleep(5)

    log_debug 'sign_in_script'
    run_and_validate_success(:settings, 'sign_in.cy')
    sleep(2)

    log_debug 'check_sign_in_script'
    ensure_signed_in

    log_debug 'select_password_settings'
    run_and_validate_success(:settings, 'select_password_settings.cy')
    sleep(3)

    log_debug 'always_require_in_app_purchases'
    run_and_validate_success(:settings, 'always_require_in_app_purchases.cy')
    sleep(2)

    log_debug 'dont_require_password'
    run_and_validate_success(:settings, 'dont_require_password.cy')
    sleep(2)

    log_debug 'check_dont_require_password'
    ensure_dont_require_password

    kill_app(:settings)

    @account_changed_lambda.call
  end

  def ensure_dont_require_password
    success = false
    5.times do
      resp = run_file(:settings, 'check_dont_require_password.cy')
      if command_success?(resp)
        success = true
        break
      end
      sleep(2)
    end
    raise DontRequirePasswordFailed unless success
  end

  # should move these two ssh methods somewhere else
  def get_ssh_times
    connect
    ssh_sessions = run_command(
      "ps aux | grep sshd | grep -v grep | awk '{print $2, $9}'",
      'getting ssh times'
    ).chomp.split("\n").map do |row|
      {
        pid: row.split.first,
        time: row.split.second
      }
    end
    current_time = run_command(
      "ps aux | grep grep | awk '{print $9}'",
      'getting current time'
    ).chomp.split("\n").last
    {
      ssh_sessions: ssh_sessions,
      current_time: current_time
    }
  rescue => e
    "unable to retrieve information because of error #{e.message}"
  ensure
    disconnect
  end

  def kill_ssh_session
    connect
    run_command('killall sshd', 'kill all ssh session')
  rescue => e
    begin
      raise 'Cannot find closed stream message' unless e.message.include?('closed stream')
      check_ssh = run_command(
        'ps aux | grep sshd | grep -v grep | wc -l',
        'check remaining ssh'
      ).chomp
      check_ssh == '1' ? 'Success' : 'Error: SSH still running on device'
    rescue => e
      "Error: #{e.message}"
    end
  ensure
    disconnect
  end

  # raise exceptions if responses are exceptions...
  # otherwise just return the response
  def failed_remote_exec(command, resp)
    if resp.class.ancestors.include?(Exception)
      raise resp
    end
    resp
  end

  def verify_install_script_name
    'verify_install.cy'
  end

  def headers_using_classdump
    outfile = "#{TEMP_DIRECTORY}/#{unique_debug_id}.classdump.txt"

    inpath = get_decrypted_execs

    return inpath if !inpath # check if null
    print_display_status(:start_classdump)

    Dir.glob(File.join(inpath, '*.decrypted')).each do |file|
      class_dump(file, outfile)
    end

    outfile
  end

  def move_decrypted
    num_decrypted = run_command(
      'ls *.decrypted | wc -l',
      'find number of decrypted files'
    ).strip.to_i
    log_debug "decrypted files count: #{num_decrypted}"
    raise 'No decrypted files found' unless num_decrypted > 0

    # use system scp because it's much faster
    log_debug 'Starting download'
    print_display_status(:start_scp)

    outpath = File.join(TEMP_DIRECTORY, "#{unique_debug_id}_decrypted")
    `mkdir #{outpath}`

    system_scp('/var/root/*.decrypted', outpath, to_device: false)
    log_debug 'Download finished'

    num_transmitted = `ls #{outpath}/*.decrypted | wc -l`.strip.to_i

    raise "Expected #{num_decrypted} decrypted files. Got #{num_transmitted}" if num_decrypted != num_transmitted

    outpath
  end

  def get_decrypted_execs

    return @decrypted_path if @decrypted_path

    run_decryption
    outpath = move_decrypted

    @decrypted_path = outpath
  end

  def decryption_settings_by_device
    if @device.ios_version_fmt < IosDevice.ios_version_to_fmt_version('9.3')
      {
        user: 'root',
        output_dir: '/var/root/'
      }
    else
      {
        user: 'mobile',
        output_dir: '/var/mobile/Documents/'
      }
    end
  end

  # Decrypt app binaries and place into home of root directory
  def run_decryption
    print_display_status(:start_decrypt)
    settings = decryption_settings_by_device
    run_command(
      'rm *.decrypted /var/mobile/Documents/*.decrypted',
      'remove any leftover decrypted files'
    )

    num_execs = run_command(
      "find #{File.join(@app_info[:path], '*.app')} -maxdepth 1 -perm 755 -type f -not -name '*.*' | wc -l",
      'see how many executable files are in app'
    ).chomp

    template_type = num_execs.to_i == 1 ? :find : :bundle_info
    script_path = template_decrypt_script(template_type)
    log_debug 'Running decryption'
    decryption_command = "pushd #{settings[:output_dir]} && sudo -u #{settings[:user]} #{script_path}"
    begin
      Timeout::timeout(30) {
        run_command(decryption_command, 'run decryption command as mobile user')
      }
    rescue Timeout::Error
      pids = run_command(
        "ps aux | grep 'decryption dumper' | grep -v grep | awk '{print $2}'",
        'Get the hanging dumpdecrypted pids'
      ).chomp
      if pids.present?
        pids.split.each {|pid| run_command("kill -9 #{pid}", 'kill the decrypted pid')}
      end
    end

    log_debug 'Ensure decrypted files are in /var/root'
    run_command(
      "pushd #{settings[:output_dir]} && find *.decrypted -exec /var/root/move_decrypted.sh \"{}\" \\\;",
      'move decrypted files to a friendly name into the root directory'
    )
  end

  def template_decrypt_script(type)
    raise unless type == :find || type == :bundle_info
    log_debug 'templating decrypt scripts'
    outfile = File.join(UTIL_DEST, 'decrypt.sh')
    template_script_path = File.join('/', UTIL_DEST, 'generate_decrypt_script.sh')
    if type == :find
      run_command(
        "pushd #{UTIL_DEST} && #{template_script_path} 0 \"#{File.join(@app_info[:path], '*.app')}\" #{outfile}",
        'template find command'
      )
    else
      bundle_info = extract_bundle_info
      executable = bundle_info['CFBundleExecutable']
      raise "No executable name found" if !executable
      run_command(
        "pushd #{UTIL_DEST} && #{template_script_path} 1 \"#{File.join(@app_info[:path], @app_info[:name] + '.app', executable)}\" #{outfile}",
        'template find command'
      )
    end
    outfile
  end

  def download_headers
    classdump_filename = headers_using_classdump
    raise "Could not generate classdump" unless classdump_filename

    # Also use strings
    strings_filename = get_strings
    raise "Could not generate strings" unless strings_filename

    print_display_status(:finish_processing)

    {
      classdump_contents_path: classdump_filename,
      strings_contents_path: strings_filename,
      bundle_version: @bundle_info.present? ? @bundle_info['CFBundleShortVersionString'] : nil
    }

  end

  def get_strings
    inpath = get_decrypted_execs
    outfile = "#{TEMP_DIRECTORY}/#{unique_debug_id}.strings.txt"

    return inpath if !inpath # check if null

    print_display_status(:start_strings)

    Dir.glob(File.join(inpath, '*.decrypted')).each do |file|
      `strings #{file} >> #{outfile}`
    end

    outfile
  end

  def download_app_contents

    tar_name = "#{unique_debug_id}.tgz"
    file_tree_name = "#{unique_debug_id}.tree.txt"

    log_debug "Starting to download app contents"

    print_display_status(:building_tar)

    run_command("pushd #{@app_info[:path]} && find . > #{file_tree_name}", 'build the file tree in the install directory')

    log_debug "Created tree file"

    run_command("pushd #{@app_info[:path]} && find . -type f -exec grep . \"{}\" -Iq \\\; -and -print0 | tar cfz #{unique_debug_id}.tgz --null -T -", 'build the tar file')

    log_debug "Created tar file"

    print_display_status(:copying_tar)

    system_scp(File.join(@app_info[:path], tar_name), DECRYPTED_FOLDER, to_device: false)

    {
      app_contents_dir: DECRYPTED_FOLDER,
      app_contents_name: tar_name,
      file_tree_name: file_tree_name
    }

  end

  def build_summary
    headers_info = download_headers
    contents_info = download_app_contents

    # build summary
    summary_contents = {
      binary: {
        classdump: File.open(headers_info[:classdump_contents_path]) {|f| f.read}.scrub,
        strings: File.open(headers_info[:strings_contents_path]) {|f| f.read}.scrub
      }
    }

    # load file tree into summary
    tree_dump_path = File.join(TEMP_DIRECTORY, contents_info[:file_tree_name])
    `tar -xzf #{File.join(contents_info[:app_contents_dir], contents_info[:app_contents_name])} -C #{TEMP_DIRECTORY} #{contents_info[:file_tree_name]}`
    summary_contents[:files] = File.open(tree_dump_path) {|f| f.read}.scrub.split(/\n/)

    # load fw folders into summary
    summary_contents[:frameworks] = summary_contents[:files].map do |path|
      # regex matching Frameworks folder in root of .app directory
      match = path.match(/\.\/.*\.app\/Frameworks\/(.+)\.framework\//)
      match[1] if match
    end.compact.uniq

    # write summary to file
    summary_path = File.join(DECRYPTED_FOLDER, "#{unique_debug_id}.json.txt")
    File.open(summary_path, 'w') {|f| f.write(summary_contents.to_json)}

    print_display_status(:complete_packaging)

    {
      summary_path: summary_path,
      app_contents_path: File.join(contents_info[:app_contents_dir], contents_info[:app_contents_name]),
      bundle_version: headers_info[:bundle_version]
    }
  end

  def extract_bundle_info

    return @bundle_info if @bundle_info

    impt_keys = %w(CFBundleExecutable CFBundleShortVersionString)

    run_command("find #{File.join(@app_info[:path], '*.app')} -maxdepth 1 -name 'Info.plist' -exec plutil -convert json '{}' \\\;", 'Converting plist to json', 'Converted 1 files to json format')
    begin
      bundle_info = JSON.parse(run_command("find #{File.join(@app_info[:path], '*.app')} -maxdepth 1 -name 'Info.json' -exec cat '{}' \\\;", 'Echoing json plist file').chomp)
    rescue JSON::ParserError => e
      # go with backup method of extracting important keys one by one
      bundle_info = {}
      impt_keys.each do |key|
        value = run_command("find #{File.join(@app_info[:path], '*.app')} -maxdepth 1 -name 'Info.plist' -exec plutil -key #{key} '{}' \\\;", "Getting key #{key} from the main plist").chomp
        bundle_info[key] = value
      end
    end

    # see if Base.lproj and en.lproj exists and overwrite. Order matters
    extra_plist_directories = [
      'Base.lproj',
      'en.lproj'
    ];

    extra_plist_directories.each do |dir|

      res = run_command("find #{File.join(@app_info[:path], '*.app')} -maxdepth 2 -name 'InfoPlist.strings' -path '*/#{dir}/*' | wc -l", "Seeing if #{dir} has an InfoPlist.strings file")

      if res && res.chomp == '1'
        run_command("find #{File.join(@app_info[:path], '*.app')} -maxdepth 2 -name 'InfoPlist.strings' -path '*/#{dir}/*' -exec plutil -convert json '{}' \\\;", 'Converting plist to json', 'Converted 1 files to json format')

        begin
          more_data = JSON.parse(run_command("find #{File.join(@app_info[:path], '*.app')} -maxdepth 2 -name 'InfoPlist.json' -path '*/#{dir}/*' -exec cat '{}' \\\;").chomp)
        rescue
          more_data = {}
        end
        bundle_info.merge!(more_data)
      end
    end
    @bundle_info = bundle_info
  end

  def teardown
    print_display_status(:begin_teardown)
    run_command('rm *.decrypted', 'remove all decrypted files')
    delete_applications_v2
    sleep(1) # sometimes deleting the app isn't instantaneous

    clean_up_scripts
    kill_app(:app_store)

    # validate that it was deleted
    apps = current_installed_apps
    raise 'Teardown unsuccessful: app is still installed' if apps.include?(@app_info[:path].split('/').last)
  end

  def installed_bundle_ids
    bundle_ids = run_command("find #{apps_install_path} -maxdepth 2 -name '.com.apple.mobile_container_manager*' -exec plutil -key MCMMetadataIdentifier '{}' \\\;", 'Get installed bundle ids') || ''
    bundle_ids = bundle_ids.chomp.split(/\n/)

    bundle_ids.reject do |id|
      /com\.wanmei\.mini\.condorpp/.match(id) ||
        /com\.e4bf058461/.match(id) ||
        /com\.datachowder\.yalu102/.match(id) # :tada:
    end
  end

  def delete_applications_v2
    files = %w(
    1_delete_app_ios9.cy
    2_ensure_uninstalled_ios9.cy
    3_unlock_device_ios9.cy
    3_unlock_device_ios10.cy
    )

    apps = current_installed_apps

    return "Nothing to do" if apps.empty?

    # get the bundle ids of all the apps
    bundle_ids = installed_bundle_ids

    # template the file
    files.each do |fname|
      script = File.open(File.join(UTIL_SRC, fname), 'rb') { |f| f.read } % [bundle_ids.join(",")]
      template_file(fname, script)
    end

    # run the files
    log_debug 'deleting the apps'
    run_file(:springboard, '1_delete_app_ios9.cy')
    log_debug 'monitor uninstall'
    monitor_uninstall
    log_debug 'restart'
    kill_app(:springboard)
    sleep(13)
    log_debug 'unlocking'
    unlock_device
    sleep(2)
    log_debug 'Done'
  end

  def unlock_device
    if @device.ios_version_fmt >= IosDevice.ios_version_to_fmt_version('10.0')
      run_file(:springboard, '3_unlock_device_ios10.cy')
    else
      run_file(:springboard, '3_unlock_device_ios9.cy')
    end
  end

  def monitor_uninstall
    t = Time.now
    while Time.now - t < 300 # 5 minutes to delete...should only take a couple seconds
      sleep(5)
      log_debug "check if apps are gone"
      resp = run_file(:springboard, '2_ensure_uninstalled_ios9.cy')
      if resp && resp.include?('all gone')
        break
      else
        log_debug resp.chomp if resp
      end
      puts ''
    end
    log_debug Time.now - t
  end

  def unique_debug_id
    @classdump_id
  end

  # removed class-dump in favor of jtool during processing
  def class_dump(src, dest)
    `echo > #{dest}`
    # arch = @device.class_dump_arch || "arm64"
    # accepted_arches = `/usr/local/bin/class-dump --list-arches \'#{src}\'`.split
    # arch_flag = accepted_arches.include?(arch) ? "--arch #{arch}" : "" # let class-dump decide if not
    # `/usr/local/bin/gtimeout 1m /usr/local/bin/class-dump #{arch_flag} \'#{src}\' >> \'#{dest}\' 2>/dev/null`
  end

  def upload_decrypted_execs
    decrypted_dir = get_decrypted_execs
    Dir.glob(File.join(decrypted_dir, '*.decrypted')).each do |file|
      MightyAws::S3.new(Rails.application.config.ipa_bucket_region).upload_file(
        bucket: Rails.application.config.ipa_bucket,
        key_path: File.join('decrypted_binaries', @classdump_id.to_s, file.split('/').last),
        file_path: file
      )
    end
  end

  class << self
    def test(ios_device_id: 1, change_account: false, ipa_snapshot_id: nil)
      device = IosDevice.find(ios_device_id)
      ipa_snapshot = ipa_snapshot_id.nil? ? IpaSnapshot.last : IpaSnapshot.find(ipa_snapshot_id)
      lookup_content = JSON.parse(ipa_snapshot.lookup_content)
      acct_lambda = change_account ? -> { puts 'changed account lambda' } : nil
      id = rand(1_000_000)
      new(device, apple_account: device.apple_account, account_changed_lambda: acct_lambda)
        .run(lookup_content['trackId'], lookup_content, :one_off, id) do |incomplete_result|
        puts 'hey'
      end
    end
  end
end
