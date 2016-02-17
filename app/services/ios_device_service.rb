require 'net/scp'
require 'shellwords'

class IosDeviceService

  DEVICE_USERNAME = 'root'
  DEVICE_PASSWORD = 'padmemyboo'

  OPEN_APP_SCRIPT_PATH = './server/open_app.cy'
  DOWNLOAD_APP_SCRIPT_PATH = './server/download_app.cy'
  DEBUG_SCRIPT_PATH = './server/debug_status_method.cy'
  VERIFY_INSTALL_SCRIPT_PATH = './server/verify_install.cy'

  APPS_INSTALL_PATH = "/var/mobile/Containers/Bundle/Application/"

  DELETE_APP_STEPS_DIR = './server/delete_app_steps'
  BACKTRACE_SIZE = 5

  TEMP_DIRECTORY = '/tmp'

  home = `echo $HOME`.chomp
  DECRYPTED_FOLDER = "#{home}/decrypted_ios_apps"

  DISPLAY_STATUSES = {
    downloading: {
      commands: "updateDebugStatus('Waiting for download', [UIColor yellowColor]);",
      filename: 'download_waiting.cy'
    },
    download_complete: {
      commands: "updateDebugStatus('Finished download', [UIColor greenColor]);",
      filename: 'download_complete.cy'
    },
    start_decrypt: {
      commands: "updateDebugStatus('Running Decrypt', [UIColor yellowColor]);",
      filename: 'start_decrypt.cy'
    },
    start_scp: {
      commands: "updateDebugStatus('SCP Binary', [UIColor yellowColor]);",
      filename: 'start_scp.cy'
    },
    start_classdump: {
      commands: "updateDebugStatus('Running ClassDump', [UIColor yellowColor]);",
      filename: 'start_classdump.cy'
    },
    start_strings: {
      commands: "updateDebugStatus('Running Strings', [UIColor yellowColor]);",
      filename: 'start_strings.cy'
    },
    finish_processing: {
      commands: "updateDebugStatus('Finished Processing Decrypted File', [UIColor greenColor]);",
      filename: 'finish_processing.cy'
    },
    building_tar: {
      commands: "updateDebugStatus('Building Tar file', [UIColor yellowColor]);",
      filename: 'building_tar.cy'
    },
    copying_tar: {
      commands: "updateDebugStatus('SCP Tar', [UIColor yellowColor]);",
      filename: 'copying_tar.cy'
    },
    complete_packaging: {
      commands: "updateDebugStatus('Finished summary', [UIColor greenColor]);",
      filename: 'complete_packaging.cy'
    },
    s3_upload: {
      commands: "updateDebugStatus('Starting s3 upload', [UIColor yellowColor]);",
      filename: 's3_upload.cy'
    },
    begin_teardown: {
      commands: "updateDebugStatus('Beginning uninstall', [UIColor greenColor]);",
      filename: 'begin_teardown.cy'
    }
  }

  def initialize(device)
    @device = device
    @bundle_info = nil
    @decrypted_file = nil
    @decrypted_path = nil
  end

  def run_command(ssh, command, description, expected_output = nil)
    begin
      # add additional check to ensure cycript command doesn't hang indefinitely
      is_cycript = /cycript -p (\w+)/.match(command)
      if (is_cycript && !(ssh.exec! "ps aux | grep #{is_cycript[1]} | grep -v grep"))
        raise "Running cycript on app #{is_cycript[1]} but app is not running or crashed"
      end
      resp = ssh.exec! command
      if expected_output != nil && resp.chomp != expected_output
        raise "Expected output #{expected_output}. Received #{resp.chomp}"
      end
      return resp
    rescue => error
      raise "Error during #{description} with command: #{command}. Message: #{error.message}"
    end
  end

  # Returns the current time
  def get_ssh_times
    begin
      Net::SSH.start(@device.ip, DEVICE_USERNAME, :password => DEVICE_PASSWORD) do |ssh|
        ssh_sessions = run_command(ssh, "ps aux | grep sshd | grep -v grep | awk '{print $2, $9}'", 'getting ssh times').chomp.split("\n").map do |row|
          {
            pid: row.split.first,
            time: row.split.second
          }
        end
        current_time = run_command(ssh, "ps aux | grep grep | awk '{print $9}'", 'getting current time').chomp.split("\n").last
        {
          ssh_sessions: ssh_sessions,
          current_time: current_time
        }
      end
    rescue => e
      "unable to retrieve information because of error #{e.message}"
    end
  end

  def kill_ssh_session
    begin
      Net::SSH.start(@device.ip, DEVICE_USERNAME, :password => DEVICE_PASSWORD) do |ssh|
        kill = run_command(ssh, "killall sshd", 'kill all ssh sessions')
      end
    rescue => e
      begin
        raise "Cannot find closed stream message" if !e.message.include?('closed stream')
        Net::SSH.start(@device.ip, DEVICE_USERNAME, :password => DEVICE_PASSWORD) do |ssh|
          check_ssh = run_command(ssh, 'ps aux | grep sshd | grep -v grep | wc -l', 'checking remaining ssh').chomp
          if check_ssh != '1'
            "Error: SSH still running on device"
          else
            "Success"
          end
        end
      rescue => e
        "Error: #{e.message}"
      end
    end
  end

  def run(app_identifier, lookup_content, purpose, unique_id, country_code: 'us')

    @app_identifier = app_identifier
    @lookup_content = lookup_content
    @unique_id = unique_id
    @purpose = purpose

    def format_backtrace(backtrace)
      backtrace  # just return the trace
    end

    result = {
      success: false,
      install_success: false,
      dump_success: false,
      teardown_success: false,
      teardown_retry: false,
      timestamp: Time.now,
    }

    app_info = nil

    begin
      Net::SSH.start(@device.ip, DEVICE_USERNAME, :password => DEVICE_PASSWORD) do |ssh|
        begin
          install_debug_script(ssh)
          install_display_statuses(ssh)
          app_info = install(ssh, app_identifier, country_code)
          result[:install_time] = Time.now
          result[:install_success] = true

          yield(result) if block_given?

          result.merge!(build_summary(ssh, app_info))
          # result.merge!(download_headers(ssh, app_info))

          result[:dump_time] = Time.now
          result[:dump_success] = true

          print_display_status(ssh, :s3_upload)
          yield(result) if block_given?

          teardown(ssh, app_info)

          result[:teardown_success] = true
          result[:teardown_time] = Time.now
          result[:success] = true
        rescue => error
          result[:error] = error.message
          result[:trace] = format_backtrace(error.backtrace)
          if error.cause
            result[:error_root] = error.cause.message
            result[:trace] = format_backtrace(error.cause.backtrace)
          end

          # if it succeeds downloading but dump fails, continue to the tear down step
          if result[:install_success] && !result[:teardown_success]
            begin
              teardown(ssh, app_info)
              result[:teardown_success] = true
            rescue => teardown_error
              result[:error_teardown] = teardown_error.message
              result[:error_teardown_trace] = format_backtrace(error.backtrace)
            end
          end
        end
      end
    rescue => error # ssh errors
      result[:error] = error.message
      result[:error_trace] = format_backtrace(error.backtrace)
      result[:error_code] = :ssh_failure if error.class == Errno::ETIMEDOUT
    end

    # if teardown was still unsuccessful, try again. Likely because ssh booted when classdump failed
    begin
      if result[:install_success] && !result[:teardown_success]
        Net::SSH.start(@device.ip, DEVICE_USERNAME, :password => DEVICE_PASSWORD) do |ssh|
          result[:teardown_retry] = true
          teardown(ssh, app_info)
          result[:teardown_success] = true
          result[:teardown_time] = Time.now
          result[:success] = true if result[:dump_success] # have completed everything
        end
      end
    rescue => e
    end



    # make times into durations (except timestamp). Array order matters
    timestops = [:teardown_time, :dump_time, :install_time, :timestamp]
    timestops[0..-2].each_with_index do |value, index|
      result[timestops[index]] = result[timestops[index]] - result[timestops[index+1]] if (result[timestops[index]] && result[timestops[index+1]])
    end

    result[:duration] = Time.now - result[:timestamp]
    # last time, update status
    if result[:install_success] && result[:dump_success] && result[:teardown_success]
      result[:success] = true
    end

    # send results to database
    result
  end

  # check if the app store is running
  # returns a boolean
  def is_app_store_running?(ssh)
    ret = run_command(ssh, 'ps aux | grep AppStore | grep -v grep | wc -l', 'check if app store is open')
    ret && ret.include?('0') ? false : true
  end

  # open app and bind debug method
  # assumes both cycript scripts for both have been installed
  def open_app_in_app_store(ssh)
    run_command(ssh, 'cycript -p SpringBoard open_app_in_app_store.cy', 'opening app in store script')
    sleep(1)
    run_command(ssh, "cycript -p AppStore #{debug_script_name}", 'add debug method to AppStore runtime')
  end

  def open_app_store(ssh)
    run_command(ssh, 'open com.apple.AppStore', 'opening app in store script')
    sleep(2)
    run_command(ssh, "cycript -p AppStore #{debug_script_name}", 'add debug method to AppStore runtime')
  end

  def install(ssh, app_identifier, country_code = "us")

    run_command(ssh, 'killall AppStore', 'Restarting AppStore')
    run_command(ssh, 'rm -f open_app.cy', 'Deleting old open_app.cy')
    run_command(ssh, "echo '[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@\"itms-apps://itunes.apple.com/#{country_code}/app/id#{app_identifier}?mt=8\"]]' > open_app_in_app_store.cy", 'Adding open_app_in_app_store.cy')
    run_command(ssh, "echo '[[SBUIController sharedInstance] clickedMenuButton];' > press_home_button.cy", 'Adding press_home_button.cy')
    open_app_in_app_store(ssh)

    prior_apps = run_command(ssh, "ls #{APPS_INSTALL_PATH}", 'get bundles before install')
    if prior_apps == nil
      prior_apps = []
    else
      prior_apps = prior_apps.chomp.split
    end
    puts "prior_apps: #{prior_apps.join(' ')}"

    install_download_app_script(ssh)

    first_step_success = false
    # open app page in app store
    10.times do |n|
      # make sure app store is open
      if !is_app_store_running?(ssh)
        puts "AppStore not open, opening app again"
        open_app_in_app_store(ssh)
      end
      puts "Waiting 3s..."
      sleep(3)
      puts "Try #{n}"
      ret = run_command(ssh, "cycript -p AppStore #{download_app_script_name}", 'click download app')
      # could be timing error if download succeeds in less than 3 seconds...
      if ret && (ret.include?('Downloading'))
        puts "Download started"
        first_step_success = true
        break
      elsif ret && ret.include?('Installed')
        puts "Already installed"
        raise "App already installed and ambiguous prior installs or mistaken OPEN button" if prior_apps.length != 1
        prior_apps = [] # assured only 1 and it's already installed. shortcut to let apps_after succeed
        first_step_success = true
        break
      elsif ret && ret.include?('Pressed button')
        puts "Pressed button"
      else
        puts "Did not start downloading"
      end
    end

    raise "Unable to initiate download" if !first_step_success
    
    # add some logic to ensure that app store is open

    install_open_app_scripts(ssh)

    # wait for download and open app
    wait_time = @purpose == :mass ? 120 : 48 # 10 vs 4 minutes
    wait_time.times do |n| # 2 minutes

      # make sure app store is open
      if !is_app_store_running?(ssh)
        puts "AppStore not open, opening app again"
        open_app_in_app_store(ssh)
      end
      puts "Waiting 5s..."
      sleep(5)
      puts "Try #{n}"

      # button_check = run_command(ssh, "cycript -p AppStore #{open_app_script_name}", 'find open app after download')

      bundle_check = run_command(ssh, "cycript -p SpringBoard #{verify_install_script_name}", 'check SpringBoard for app')

      if bundle_check && bundle_check.chomp.include?('Completed')
        puts "Finished install"
        print_display_status(ssh, :download_complete)
        break
      else
        print_display_status(ssh, :downloading)
        puts "Not downloaded yet"
      end

      puts ''
    end

    apps_after = run_command(ssh, "ls #{APPS_INSTALL_PATH}", 'get bundles after install')
    if apps_after == nil
      raise "No applications installed, so download failed"
    end

    apps_after = apps_after.chomp.split
    puts "apps after: #{apps_after.join(' ')}"

    if apps_after.length <= prior_apps.length
      raise "No new installs. Install failed"
    end

    bundle_check = run_command(ssh, "cycript -p SpringBoard #{verify_install_script_name}", 'check SpringBoard for app')

    if !(bundle_check && bundle_check.include?('Completed'))
      raise "Springboard cannot locate newly installed app. Likely install timeout"
    end

    # find the new one and return it
    new_app_folder = apps_after.select { |id| !prior_apps.include? id }.first
    get_app_name_and_path(ssh, new_app_folder)
  end

  def install_display_statuses(ssh)
    DISPLAY_STATUSES.keys.each do |key|
      command = DISPLAY_STATUSES[key][:commands]
      filename = DISPLAY_STATUSES[key][:filename]
      run_command(ssh, "echo \"#{command}\" > #{filename}", 'installing a display debug script')
    end
  end

  # Install the download_app_script if it's not already there
  def install_download_app_script(ssh)

    script = File.open(DOWNLOAD_APP_SCRIPT_PATH, 'rb') { |f| f.read }
    run_command(ssh, "echo '#{script}' > #{download_app_script_name}", 'writing download script to file')
  end

  # TODO: remove the old one...not used anymore
  def install_open_app_scripts(ssh)
    bundle_id = @lookup_content['bundleId']

    raise "no bundle id available" if bundle_id.nil?

    script = File.open(OPEN_APP_SCRIPT_PATH, 'rb') { |f| f.read }
    run_command(ssh, "echo '#{script}' > #{open_app_script_name}", 'writing open script to file')

    script = File.open(VERIFY_INSTALL_SCRIPT_PATH, 'rb') { |f| f.read } % [bundle_id]
    run_command(ssh, "echo '#{script}' > #{verify_install_script_name}", 'writing verify script to file')

  end

  def install_debug_script(ssh)
    script = File.open(DEBUG_SCRIPT_PATH, 'rb') {|f| f.read}
    run_command(ssh, "echo '#{script}' > #{debug_script_name}", 'writing open script to file')
  end

  def download_app_script_name
    "download_app.cy"
  end

  def open_app_script_name
    "open_app.cy"
  end

  def verify_install_script_name
    "verify_install.cy"
  end

  def debug_script_name
    "debug_status_method.cy"
  end

  def get_app_name_and_path(ssh, new_app_folder = nil)
    if !new_app_folder
      # this assumes app is most recently installed (not always true)
      new_app_folder = run_command(ssh, "ls -1t #{APPS_INSTALL_PATH}", 'list all installed bundles').chomp.split("\n").first.chomp
    end

    new_path = APPS_INSTALL_PATH + new_app_folder
    app_name = run_command(ssh, "ls -1 #{new_path} | grep \".*\.app\"", 'get app directory').chomp.split("\n").first.chomp.gsub('.app', '')

    return {
      name: app_name,
      name_escaped: Shellwords.escape(app_name), # command line safe version
      path: Shellwords.escape(new_path)
    }
  end

  def get_decrypted_execs(ssh, app_info)

    return @decrypted_path if @decrypted_path


    outpath = File.join(TEMP_DIRECTORY, "#{@unique_id}_decrypted")
    `mkdir #{outpath}`

    print_display_status(ssh, :start_decrypt)

    run_command(ssh, "rm *.decrypted", 'remove any leftover decrypted files')
    num_execs = run_command(ssh, "find #{File.join(app_info[:path], '*.app')} -maxdepth 1 -perm 755 -type f -not -name '*.*' | wc -l", 'see how many executable files are in app').chomp

    decrypt_command = if num_execs == '1'
      puts "#{@unique_id}: Found 1 executable"
      "find #{File.join(app_info[:path], '*.app')} -maxdepth 1 -perm 755 -type f -not -name '*.*' -exec /bin/bash -c \"DYLD_INSERT_LIBRARIES=/var/root/dumpdecrypted.dylib '{}' mach-o decryption dumper\" \\\;"
    else
      puts "#{@unique_id}: Found other number of executables: #{num_execs}"

      bundle_info = extract_bundle_info(ssh, app_info)
      
      executable = bundle_info['CFBundleExecutable']
      raise "No executable name found" if !executable

      "DYLD_INSERT_LIBRARIES=$PWD/dumpdecrypted.dylib \"#{app_info[:path]}/#{app_info[:name]}.app/#{executable}\" mach-o decryption dumper"
    end

    begin
      Timeout::timeout(30) {
        run_command(ssh, decrypt_command, "Use dumpdecrypted to decrypt")
      }
    rescue Timeout::Error
      pids = run_command(ssh, "ps aux | grep 'decryption dumper' | grep -v grep | awk '{print $2}'", 'Get the hanging dumpdecrypted pids').chomp
      if pids.present?
        pids.split.each {|pid| run_command(ssh, "kill -9 #{pid}", 'kill the decrypted pid')}
      end
    end

    # move it to a non-spaced name for scp'ing later (combo of sh + scp messes up with spaces)
    num_decrypted = run_command(ssh, "ls *.decrypted | wc -l", 'find number of decrypted files').strip.to_i

    puts "#{@unique_id}: decrypted files count: #{num_decrypted}"

    # create entries 
    run_command(ssh, "find *.decrypted -exec ./move_decrypted.sh \"{}\" \\\;", 'move decrypted files to a friendly name')

    if num_decrypted > 1
      num_decrypted = run_command(ssh, "ls *.decrypted | wc -l", 'find number of decrypted files').strip.to_i

      puts "#{@unique_id}: decrypted count after renaming: #{num_decrypted}"
    end

    # use system scp because it's much faster
    puts "Starting download"
    print_display_status(ssh, :start_scp)

    `/usr/local/bin/sshpass -p #{DEVICE_PASSWORD} scp #{DEVICE_USERNAME}@#{@device.ip}:/var/root/*.decrypted #{outpath}`
    puts "Download finished"

    # TODO: validate
    num_transmitted = `ls #{outpath}/*.decrypted | wc -l`.strip.to_i

    raise "Expected #{num_decrypted} decrypted files. Got #{num_transmitted}" if num_decrypted != num_transmitted
    @decrypted_path = outpath

  end

  # decrypts and scp's executable from device into temp directory
  # only runs once per instance
  # NOTE: this means you should not delete it once it's there until the teardown stage
  # def get_decrypted_exec(ssh, app_info)

  #   return @decrypted_file if @decrypted_file

  #   bundle_info = extract_bundle_info(ssh, app_info)

  #   outfile = "#{@unique_id}.decrypted"

  #   print_display_status(ssh, :start_decrypt)

  #   run_command(ssh, "rm *.decrypted", 'remove any leftover decrypted files')
  #   num_execs = run_command(ssh, "find #{File.join(app_info[:path], '*.app')} -maxdepth 1 -perm 755 -type f -not -name '*.*' | wc -l", 'see how many executable files are in app').chomp

  #   decrypt_command = if num_execs == '1'
  #     puts "#{@unique_id}: Found 1 executable"
  #     "find #{File.join(app_info[:path], '*.app')} -maxdepth 1 -perm 755 -type f -not -name '*.*' -exec /bin/bash -c \"DYLD_INSERT_LIBRARIES=/var/root/dumpdecrypted.dylib '{}' mach-o decryption dumper\" \\\;"
  #   else
  #     puts "#{@unique_id}: Found other number of executables: #{num_execs}"

  #     executable = bundle_info['CFBundleExecutable']
  #     raise "No executable name found" if !executable

  #     "DYLD_INSERT_LIBRARIES=$PWD/dumpdecrypted.dylib \"#{app_info[:path]}/#{app_info[:name]}.app/#{executable}\" mach-o decryption dumper"
  #   end

  #   begin
  #     Timeout::timeout(30) {
  #       run_command(ssh, decrypt_command, "Use dumpdecrypted to decrypt")
  #     }
  #   rescue Timeout::Error
  #     pids = run_command(ssh, "ps aux | grep 'decryption dumper' | grep -v grep | awk '{print $2}'", 'Get the hanging dumpdecrypted pids').chomp
  #     if pids.present?
  #       pids.split.each {|pid| run_command(ssh, "kill -9 #{pid}", 'kill the decrypted pid')}
  #     end
  #   end

  #   # if there's 1 decrypted file (as expected), use the old process

  #   # move it to a non-spaced name for scp'ing later (combo of sh + scp messes up with spaces)
  #   run_command(ssh, "find . -maxdepth 1 -name '*.decrypted' -exec mv '{}' #{outfile} \\\;", 'move it to a name without spaces for scp\'ing')

  #   # use system scp because it's much faster
  #   puts "Starting download"
  #   print_display_status(ssh, :start_scp)

  #   `/usr/local/bin/sshpass -p #{DEVICE_PASSWORD} scp #{DEVICE_USERNAME}@#{@device.ip}:/var/root/#{outfile} #{TEMP_DIRECTORY}`
  #   puts "Download finished"

  #   # validate
  #   exists = `[ -f #{TEMP_DIRECTORY}/#{outfile} ] && echo 'exists' || echo 'dne'`.chomp

  #   if exists != 'exists'
  #     raise "Could not get decrypted app from device"
  #   end

  #   @decrypted_file = "#{TEMP_DIRECTORY}/#{outfile}"
  # end

  # execute any of the dump status commands against the AppStore
  def print_display_status(ssh, status)
    if !is_app_store_running?(ssh)
      open_app_store(ssh)
    end

    raise "Status #{status} is not valid" if DISPLAY_STATUSES[status].nil?
    run_command(ssh, "cycript -p AppStore #{DISPLAY_STATUSES[status][:filename]}", "Printing debug statement #{status}")
  end

  def build_summary(ssh, app_info)

    headers_info = download_headers(ssh, app_info)
    contents_info = download_app_contents(ssh, app_info)

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
    summary_path = File.join(DECRYPTED_FOLDER, "#{@unique_id}.json.txt")
    File.open(summary_path, 'w') {|f| f.write(summary_contents.to_json)}

    print_display_status(ssh, :complete_packaging)

    {
      summary_path: summary_path,
      app_contents_path: File.join(contents_info[:app_contents_dir], contents_info[:app_contents_name]),
      bundle_version: headers_info[:bundle_version]
    }
  end

  def download_app_contents(ssh, app_info)

    tar_name = "#{@unique_id}.tgz"
    file_tree_name = "#{@unique_id}.tree.txt"

    puts "Starting to download app contents"

    print_display_status(ssh, :building_tar)

    run_command(ssh, "pushd #{app_info[:path]} && find . > #{file_tree_name}", 'build the file tree in the install directory')

    puts "Created tree file"

    run_command(ssh, "pushd #{app_info[:path]} && find . -type f -exec grep . \"{}\" -Iq \\\; -and -print0 | tar cfz #{@unique_id}.tgz --null -T -", 'build the tar file')

    puts "Created tar file"

    print_display_status(ssh, :copying_tar)

    `/usr/local/bin/sshpass -p #{DEVICE_PASSWORD} scp #{DEVICE_USERNAME}@#{@device.ip}:#{File.join(app_info[:path], tar_name)} #{DECRYPTED_FOLDER}`

    puts "Downloaded tar file"

    {
      app_contents_dir: DECRYPTED_FOLDER,
      app_contents_name: tar_name,
      file_tree_name: file_tree_name
    }

  end

  def download_headers(ssh, app_info)

    classdump_filename = headers_using_classdump(ssh, app_info)

    # validate that decrypting was possible
    raise "Could not generate classdump" unless classdump_filename

    # Also use strings
    strings_filename = get_strings(ssh, app_info)

    raise "Could not generate strings" unless strings_filename

    # # validate contents. Should use strings as a backup
    # contents = File.open(filename, 'rb') { |f| f.read }
    # if !(/Generated by class-dump/.match(contents) && !(/This file is encrypted/).match(contents))

    #   # remove the old empty file
    #   `rm -f #{filename}`

    #   # TODO: add some strings validation
    #   filename = get_strings(ssh, app_info)

    #   if !filename
    #     raise "Could not generate strings"
    #   end

    #   method = "strings"
    # end

    # Check for frameworks folder and add it to the file
    # listed_frameworks = get_listed_frameworks(ssh, app_info)
    # if !listed_frameworks.nil?
    #   listed_frameworks.split(/\n/).each do |framework|
    #     `echo Folder:#{framework} >> #{filename}`
    #   end
    #   has_fw_folder = true
    # end

    print_display_status(ssh, :finish_processing)

    {
      classdump_contents_path: classdump_filename,
      strings_contents_path: strings_filename,
      bundle_version: @bundle_info.present? ? @bundle_info['CFBundleShortVersionString'] : nil
    }

  end

  def teardown(ssh, app_info)

    print_display_status(ssh, :begin_teardown)
    delete_applications_v2(ssh)
    sleep(1) # sometimes deleting the app isn't instantaneous

    run_command(ssh, 'rm /var/root/*.decrypted', 'removing all decrypted files from root home directory')
    run_command(ssh, 'rm /var/root/*.cy', 'removing all cycript files')
    run_command(ssh, 'killall AppStore', 'kill the app store')

    # validate that it was deleted
    resp = run_command(ssh, "[ -d #{app_info[:path]} ] && echo 'exists' || echo 'dne'", 'check if app bundle exists').chomp
    if resp == 'exists'
      raise "Teardown unsuccessful: app is still installed"
    end
  end

  # Some apps have frameworks folder. Returns string of them or nil if non available
  def get_listed_frameworks(ssh, app_info)

    resp = run_command(ssh, "find #{File.join(app_info[:path], '*.app')} -mindepth 1 -maxdepth 1 -type d -name 'Frameworks' | wc -l", 'check if Frameworks folder exists').chomp

    return nil unless resp == '1'

    frameworks = run_command(ssh, "find #{File.join(app_info[:path], '*.app', 'Frameworks')} -maxdepth 1 -name '*.framework' | awk -F '/' '{print $NF}' | cut -d '.' -f1", 'Get all the frameworks in the Frameworks folder')

    frameworks.chomp if !frameworks.nil? && !frameworks.chomp.empty?
  end

  ################ not used currently ################
  # def headers_using_classdump_dyld(ssh, app_info)

  #   puts "classdump-dyld #{app_info[:path]}/#{app_info[:name_escaped]}.app/ > #{app_info[:name_escaped]}.classdumpdylib"

  #   puts "/var/root/#{app_info[:name]}.classdumpdylib"

  #   run_command(ssh, "classdump-dyld #{app_info[:path]}/#{app_info[:name_escaped]}.app/ > #{app_info[:name_escaped]}.classdumpdylib", 'run classdump-dyld')

  #   # SCP does it's own escaping...so don't use escaped name
  #   Net::SCP.download!(@device.ip, DEVICE_USERNAME, "/var/root/#{app_info[:name]}.classdumpdylib", DECRYPTED_FOLDER, ssh: { password: DEVICE_PASSWORD })

  #   return "#{DECRYPTED_FOLDER}/#{app_info[:name]}.classdumpdylib"
  # end

  def extract_bundle_info(ssh, app_info)

    return @bundle_info if @bundle_info

    # get defaults in Info.plist
    # path_to_app = "#{app_info[:path]}/#{app_info[:name_escaped]}.app"

    impt_keys = %w(CFBundleExecutable CFBundleShortVersionString)

    # run_command(ssh, "plutil -convert json #{File.join(path_to_app, 'Info.plist')}", 'Converting plist to json', "Converted 1 files to json format")

    run_command(ssh, "find #{File.join(app_info[:path], '*.app')} -maxdepth 1 -name 'Info.plist' -exec plutil -convert json '{}' \\\;", 'Converting plist to json', 'Converted 1 files to json format')
    begin
      # bundle_info = JSON.parse(run_command(ssh, "cat #{File.join(path_to_app, 'Info.json')}", 'Echoing json plist file').chomp)
      bundle_info = JSON.parse(run_command(ssh, "find #{File.join(app_info[:path], '*.app')} -maxdepth 1 -name 'Info.json' -exec cat '{}' \\\;", 'Echoing json plist file').chomp)
    rescue JSON::ParserError => e
      # go with backup method of extracting important keys one by one
      bundle_info = {}
      # TODO: make sure these commands work
      impt_keys.each do |key|
        # value = run_command(ssh, "plutil -key #{key} #{File.join(path_to_app, 'Info.plist')}", "Getting key #{key} from the main plist").chomp
        value = run_command(ssh, "find #{File.join(app_info[:path], '*.app')} -maxdepth 1 -name 'Info.plist' -exec plutil -key #{key} '{}' \\\;", "Getting key #{key} from the main plist").chomp
        bundle_info[key] = value
      end
    end

    # see if Base.lproj and en.lproj exists and overwrite. Order matters
    extra_plist_directories = [
      'Base.lproj',
      'en.lproj'
    ];

    extra_plist_directories.each do |dir|

      res = run_command(ssh, "find #{File.join(app_info[:path], '*.app')} -maxdepth 2 -name 'InfoPlist.strings' -path '*/#{dir}/*' | wc -l", "Seeing if #{dir} has an InfoPlist.strings file")

      if res && res.chomp == '1'
        run_command(ssh, "find #{File.join(app_info[:path], '*.app')} -maxdepth 2 -name 'InfoPlist.strings' -path '*/#{dir}/*' -exec plutil -convert json '{}' \\\;", 'Converting plist to json', 'Converted 1 files to json format')

        begin
          more_data = JSON.parse(run_command(ssh, "find #{File.join(app_info[:path], '*.app')} -maxdepth 2 -name 'InfoPlist.json' -path '*/#{dir}/*' -exec cat '{}' \\\;").chomp)
        rescue
          more_data = {}
        end

        bundle_info.merge!(more_data)
      end

      # res = run_command(ssh, "[ -d #{app_info[:path]}/#{app_info[:name_escaped]}.app/#{dir}/ ] && [ -f #{app_info[:path]}/#{app_info[:name_escaped]}.app/#{dir}/InfoPlist.strings ] && echo 'exists'", "Seeing if #{dir} and InfoPlist.strings exist")

      # if res && res.chomp == 'exists'
      #   run_command(ssh, "plutil -convert json #{app_info[:path]}/#{app_info[:name_escaped]}.app/#{dir}/InfoPlist.strings", 'Converting plist to json', "Converted 1 files to json format")

      #   begin
      #     more_data = JSON.parse(run_command(ssh, "cat #{app_info[:path]}/#{app_info[:name_escaped]}.app/#{dir}/InfoPlist.json", 'Echoing json plist file'))
      #   rescue
      #     more_data = {}
      #   end

      #   bundle_info.merge!(more_data)
      # end
    end

    # assign to @json for caching and return it
    @bundle_info = bundle_info
  end

  def delete_applications_v2(ssh)
    files = %w(1_delete_app_ios9.cy 2_ensure_uninstalled_ios9.cy 3_unlock_device_ios9.cy)

    apps = run_command(ssh, "ls #{APPS_INSTALL_PATH}", "Get installed apps")

    return "Nothing to do" if apps == nil

    apps = apps.chomp.split

    # get the bundle ids of all the apps

    bundle_ids = run_command(ssh, "find #{APPS_INSTALL_PATH} -maxdepth 2 -name '.com.apple.mobile_container_manager*' -exec plutil -key MCMMetadataIdentifier '{}' \\\;", 'Get installed bundle ids') || ''
    bundle_ids = bundle_ids.chomp.split(/\n/)
    puts "Found ids: #{bundle_ids.join(', ')}"

    # template the file
    files.each do |fname|
      script = File.open("#{DELETE_APP_STEPS_DIR}/#{fname}", 'rb') { |f| f.read } % [bundle_ids.join(",")]
      ssh.exec! "echo '#{script}' > #{fname}"
    end

    # run the files
    puts "deleting the apps"
    resp = run_command(ssh, "cycript -p SpringBoard 1_delete_app_ios9.cy", "running cycript file 1_delete_app_ios9.cy")

    t = Time.now
    while Time.now - t < 300 # 5 minutes to delete...should only take a couple seconds
      sleep(5)
      puts "check if apps are gone"
      resp = run_command(ssh, "cycript -p SpringBoard 2_ensure_uninstalled_ios9.cy", 'make sure all the apps are uninstalled')
      if resp && resp.include?('all gone')
        break
      else
        puts resp.chomp if resp
      end
      puts ''
    end
    puts Time.now - t
    # sleep(2 * bundle_ids.length) # sleep preportionally to allow kill time
    puts "#3"
    run_command(ssh, "killall SpringBoard", "killing springboard")
    sleep(13)
    puts "#4"
    resp = run_command(ssh, "cycript -p SpringBoard 3_unlock_device_ios9.cy", "unlocking the device")
    sleep(2)
    puts "Done"

  end

  # gets the classdump using class-dump tool, returns nil if it can't find executable or if dump generally fails
  # assumes in home directory of root and dumpdecrypted.dylib is there as well
  def headers_using_classdump(ssh, app_info)


    outfile = "#{TEMP_DIRECTORY}/#{@unique_id}.classdump.txt"

    inpath = get_decrypted_execs(ssh, app_info)

    return inpath if !inpath # check if null

    print_display_status(ssh, :start_classdump)

    Dir.glob(File.join(inpath, '*.decrypted')).each do |file|
      class_dump(file, outfile)
    end

    outfile
  end

  def get_strings(ssh, app_info)


    inpath = get_decrypted_execs(ssh, app_info)
    outfile = "#{TEMP_DIRECTORY}/#{@unique_id}.strings.txt"

    return inpath if !inpath # check if null

    print_display_status(ssh, :start_strings)

    Dir.glob(File.join(inpath, '*.decrypted')).each do |file|
      `strings #{file} >> #{outfile}`
    end

    outfile
  end

  def class_dump(src, dest)
    arch = @device.class_dump_arch || "arm64"
    accepted_arches = `/usr/local/bin/class-dump --list-arches \'#{src}\'`.split
    arch_flag = accepted_arches.include?(arch) ? "--arch #{arch}" : "" # let class-dump decide if not
    `/usr/local/bin/gtimeout 1m /usr/local/bin/class-dump #{arch_flag} \'#{src}\' >> \'#{dest}\' 2>/dev/null`
  end

end