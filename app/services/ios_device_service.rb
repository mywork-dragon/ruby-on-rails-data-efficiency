require 'net/scp'
require 'shellwords'

class IosDeviceService

  DOWNLOAD_APP_SCRIPT_PATH = './server/download_app.cy'
  DEVICE_USERNAME = 'root'
  DEVICE_PASSWORD = 'padme'

  OPEN_APP_SCRIPT_PATH = './server/open_app.cy'

  APPS_INSTALL_PATH = "/var/mobile/Containers/Bundle/Application/"

  DELETE_APP_STEPS_DIR = './server/delete_app_steps'
  BACKTRACE_SIZE = 5

  TEMP_DIRECTORY = '/tmp'

  home = `echo $HOME`.chomp
  DECRYPTED_FOLDER = "#{home}/decrypted_ios_apps"

  def initialize(ip)
    @ip = ip
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

  def next_account
  end

  def run(app_identifier, purpose, country_code: 'us')

    @app_identifier = app_identifier
    @purpose = purpose

    def format_backtrace(backtrace)
      backtrace[0..BACKTRACE_SIZE].join(' ---- ')
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
      Net::SSH.start(@ip, DEVICE_USERNAME, :password => DEVICE_PASSWORD) do |ssh|
        begin
          app_info = install(ssh, app_identifier, country_code)
          result[:install_time] = Time.now
          result[:install_success] = true

          yield(result) if block_given?

          result.merge!(download_headers(ssh, app_info))
          result[:dump_time] = Time.now
          result[:dump_success] = true

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
        Net::SSH.start(@ip, DEVICE_USERNAME, :password => DEVICE_PASSWORD) do |ssh|
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

  def install(ssh, app_identifier, country_code = "us")

    run_command(ssh, 'rm -f open_app.cy', 'Deleting old open_app.cy')
    run_command(ssh, "echo '[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@\"https://itunes.apple.com/#{country_code}/app/id#{app_identifier}\"]]' > open_app_in_app_store.cy", 'Adding open_app_in_app_store.cy')
    run_command(ssh, "echo '[[SBUIController sharedInstance] clickedMenuButton];' > press_home_button.cy", 'Adding press_home_button.cy')
    run_command(ssh, 'cycript -p SpringBoard open_app_in_app_store.cy', 'opening app in store script')

    prior_apps = run_command(ssh, "ls #{APPS_INSTALL_PATH}", 'get bundles before install')
    if prior_apps == nil
      prior_apps = []
    else
      prior_apps = prior_apps.chomp.split()
    end
    puts "prior_apps: #{prior_apps.join(' ')}"

    install_download_app_script(ssh)

    # open app page in app store
    5.times do |n|
      # make sure app store is open
      run_command(ssh, 'open com.apple.AppStore', 'make sure app store is open')
      puts "Waiting 3s..."
      sleep(3)
      puts "Try #{n}"
      ret = run_command(ssh, "cycript -p AppStore #{download_app_script_name}", 'click download app') 
      if ret && ret.include?('_assert(CYRecvAll')
        puts "UI not ready"
      else
        break
      end

      puts ''
    end
    
    # add some logic to ensure that app store is open

    install_open_app_script(ssh)

    # wait for download and open app
    20.times do |n|

      # make sure app store is open
      run_command(ssh, 'open com.apple.AppStore', 'make sure app store is open')
      puts "Waiting 5s..."
      sleep(5)
      puts "Try #{n}"
      ret = run_command(ssh, "cycript -p AppStore #{open_app_script_name}", 'click open app after download')

      if ret && ret.chomp == 'Could not find OPEN button'
        puts "Not downloaded yet"
        ret = run_command(ssh, "cycript -p AppStore #{open_app_script_name}", 'open app store when not finished downloading')
      else
        break
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

    # find the new one and return it
    new_app_folder = apps_after.select { |id| !prior_apps.include? id }.first
    get_app_name_and_path(ssh, new_app_folder)
  end

  # Install the download_app_script if it's not already there
  def install_download_app_script(ssh)

    script = File.open(DOWNLOAD_APP_SCRIPT_PATH, 'rb') { |f| f.read }
    run_command(ssh, "echo '#{script}' > #{download_app_script_name}", 'writing download script to file')
  end 

  def install_open_app_script(ssh)

    script = File.open(OPEN_APP_SCRIPT_PATH, 'rb') { |f| f.read }
    run_command(ssh, "echo '#{script}' > #{open_app_script_name}", 'writing open script to file')
  end

  def download_app_script_name
    "download_app.cy"
  end

  def open_app_script_name
    "open_app.cy"
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

  # decrypts and scp's executable from device into temp directory
  # only runs once per instance
  # NOTE: this means you should not delete it once it's there until the teardown stage
  def get_decrypted_exec(ssh, app_info)

    return @decrypted_file if @decrypted_file

    bundle_info = extract_bundle_info(ssh, app_info)
    executable = bundle_info['CFBundleExecutable']

    outfile = "#{@app_identifier}.decrypted"

    # TODO: should throw or something if failed
    return executable if !executable

    run_command(ssh, "DYLD_INSERT_LIBRARIES=$PWD/dumpdecrypted.dylib \"#{app_info[:path]}/#{app_info[:name]}.app/#{executable}\" mach-o decryption dumper", "Use dumpdecrypted to decrypt")

    # move it to a non-spaced name for scp'ing later (combo of sh + scp messes up with spaces)

    run_command(ssh, "mv #{Shellwords.escape(executable)}.decrypted #{outfile}", 'move it to a name without spaces for scp\'ing')

    # use system scp because it's much faster
    puts "Starting download"
    `sshpass -p #{DEVICE_PASSWORD} scp #{DEVICE_USERNAME}@#{@ip}:/var/root/#{outfile} #{TEMP_DIRECTORY}`
    puts "Download finished"

    # validate
    exists = `[ -f #{TEMP_DIRECTORY}/#{outfile} ] && echo 'exists' || echo 'dne'`.chomp

    if exists != 'exists'
      raise "Could not get decrypted app from device"
    end

    @decrypted_file = "#{TEMP_DIRECTORY}/#{outfile}"
  end

  # for now, just move decrypted executable (revisit later)
  def move_ipa(ssh, app_info)
    decrypted_file = get_decrypted_exec(ssh, app_info)
    
    `cp #{decrypted_file} #{DECRYPTED_FOLDER}`

    "#{DECRYPTED_FOLDER}/#{decrypted_file}"
  end

  def download_headers(ssh, app_info)

    # TODO: add some logic to also use Frameworks folder
    filename = nil
    method = nil
    has_fw_folder = false

    # mass just use ipa, live scan does the processing on the machine
    if @purpose == :mass

      filename = move_ipa(ssh, app_info)
      method = "decrypted" # just decrypted file
    else

      # add in logic to insert framework_str into outputted contents
      filename = headers_using_classdump(ssh, app_info)
      method = "classdump"

      # validate that decrypting was possible
      if !filename
        raise "Could not generate classdump"
      end

      # validate contents. Should use strings as a backup
      contents = File.open(filename, 'rb') { |f| f.read }
      if !(/Generated by class-dump/.match(contents))

        # remove the old empty file
        `rm -f #{filename}`

        # TODO: add some strings validation
        filename = get_strings(ssh, app_info)

        if !filename
          raise "Could not generate strings"
        end

        method = "strings"
      end

      # Check for frameworks folder and add it to the file
      listed_frameworks = get_listed_frameworks(ssh, app_info)
      if !listed_frameworks.nil?
        listed_frameworks.split(/\n/).each do |framework|
          `echo Folder:#{framework} >> #{filename}`
        end
        has_fw_folder = true
      end
    end

    {
      outfile_path: filename,
      method: method,
      has_fw_folder: has_fw_folder
    }

  end

  def teardown(ssh, app_info)

    run_command(ssh, 'cycript -p SpringBoard press_home_button.cy', 'pressing Home button')
    delete_application(ssh, app_info)
    sleep(1) # sometimes deleting the app isn't instantaneous

    run_command(ssh, 'rm /var/root/*.decrypted', 'removing all decrypted files from root home directory')

    # validate that it was deleted
    resp = run_command(ssh, "[ -d #{app_info[:path]} ] && echo 'exists' || echo 'dne'", 'check if Frameworks folder exists').chomp
    if resp == 'exists'
      raise "Teardown unsuccessful: app is still installed"
    end
  end

  # Some apps have frameworks folder. Returns string of them or nil if non available
  def get_listed_frameworks(ssh, app_info)

    resp = run_command(ssh, "[ -d #{app_info[:path]}/#{app_info[:name_escaped]}.app/Frameworks ] && echo 'exists' || echo 'dne'", 'check if Frameworks folder exists').chomp

    return nil if resp != 'exists'

    frameworks = run_command(ssh, "ls -a #{app_info[:path]}/#{app_info[:name_escaped]}.app/Frameworks/ | grep .framework | cut -d '.' -f1", 'get frameworks in Frameworks folder')



    frameworks.chomp if !frameworks.nil? && !frameworks.chomp.empty?
  end

  ################ not used currently ################
  def headers_using_classdump_dyld(ssh, app_info)

    puts "classdump-dyld #{app_info[:path]}/#{app_info[:name_escaped]}.app/ > #{app_info[:name_escaped]}.classdumpdylib"

    puts "/var/root/#{app_info[:name]}.classdumpdylib"

    run_command(ssh, "classdump-dyld #{app_info[:path]}/#{app_info[:name_escaped]}.app/ > #{app_info[:name_escaped]}.classdumpdylib", 'run classdump-dyld')

    # SCP does it's own escaping...so don't use escaped name
    Net::SCP.download!(@ip, DEVICE_USERNAME, "/var/root/#{app_info[:name]}.classdumpdylib", DECRYPTED_FOLDER, ssh: { password: DEVICE_PASSWORD })

    return "#{DECRYPTED_FOLDER}/#{app_info[:name]}.classdumpdylib"
  end

  def extract_bundle_info(ssh, app_info)

    return @bundle_info if @bundle_info

    # get defaults in Info.plist

    run_command(ssh, "plutil -convert json #{app_info[:path]}/#{app_info[:name_escaped]}.app/Info.plist", 'Converting plist to json', "Converted 1 files to json format")

    bundle_info = JSON.parse(run_command(ssh, "cat #{app_info[:path]}/#{app_info[:name_escaped]}.app/Info.json", 'Echoing json plist file'))

    # see if Base.lproj and en.lproj exists and overwrite. Order matters
    extra_plist_directories = [
      'Base.lproj',
      'en.lproj'
    ];

    extra_plist_directories.each do |dir|

      res = run_command(ssh, "[ -d #{app_info[:path]}/#{app_info[:name_escaped]}.app/#{dir}/ ] && [ -f #{app_info[:path]}/#{app_info[:name_escaped]}.app/#{dir}/InfoPlist.strings ] && echo 'exists'", "Seeing if #{dir} and InfoPlist.strings exist")

      if res && res.chomp == 'exists'
        run_command(ssh, "plutil -convert json #{app_info[:path]}/#{app_info[:name_escaped]}.app/#{dir}/InfoPlist.strings", 'Converting plist to json', "Converted 1 files to json format")

        more_data = JSON.parse(run_command(ssh, "cat #{app_info[:path]}/#{app_info[:name_escaped]}.app/#{dir}/InfoPlist.json", 'Echoing json plist file'))

        bundle_info.merge!(more_data)
      end
    end

    # assign to @json for caching and return it
    @bundle_info = bundle_info
  end


  def delete_application(ssh, app_info)

    # need to get app's display name
    bundle_info = extract_bundle_info(ssh, app_info)
    display_name = bundle_info["CFBundleDisplayName"] || bundle_info["CFBundleName"]

    # template the scripts with the app name and copy them over

    files = `ls #{DELETE_APP_STEPS_DIR} | sort`.chomp.split("\n")
    files.each do |fname|
      script = File.open("#{DELETE_APP_STEPS_DIR}/#{fname}", 'rb') { |f| f.read } % [display_name]
      ssh.exec! "echo '#{script}' > #{fname}"
    end

    # make sure Preference page is loaded and on first page
    run_command(ssh, "open com.apple.Preferences", 'Open preference before resetting it')
    run_command(ssh, "killall Preferences", 'Kill Preferences while open')
    run_command(ssh, "open com.apple.Preferences", 'Open preference after killing it')
    sleep(2)

    files.each do |fname|
      resp = run_command(ssh, "cycript -p Preferences #{fname}", "running cycript file #{fname}")
      sleep(2)
    end
  end

  # gets the classdump using class-dump tool, returns nil if it can't find executable or if dump generally fails
  # assumes in home directory of root and dumpdecrypted.dylib is there as well
  def headers_using_classdump(ssh, app_info)

    outfile = "#{DECRYPTED_FOLDER}/#{@app_identifier}.classdump.txt"

    infile = get_decrypted_exec(ssh, app_info)

    return infile if !infile # check if null

    class_dump(infile, outfile)

    outfile

  end

  def get_strings(ssh, app_info)

    infile = get_decrypted_exec(ssh, app_info)
    outfile = "#{DECRYPTED_FOLDER}/#{@app_identifier}.txt"

    return infile if !infile # check if null

    `strings #{infile} | sort > #{outfile}`

    outfile
  end

  def class_dump(src, dest)
    `class-dump \'#{src}\' > \'#{dest}\'`
  end

end