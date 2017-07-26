# shared utilities for services interacting with ios devices
module IosDeviceUtilities

  DEVICE_USERNAME = 'root'
  DEVICE_PASSWORD = 'padmemyboo'

  SHARED_UTIL_SRC = File.join(Rails.root, 'server', 'ios_common_scripts')
  SHARED_UTIL_DEST = File.join('/var', 'root', 'ios_common_scripts')

  MAX_COMMAND_ATTEMPTS = 1

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
      },
      settings: {
        name: 'Preferences',
        bundle_id: 'com.apple.Preferences'
      }
  }

  # Error types
  class CriticalDeviceError < RuntimeError
    attr_reader :ios_device_id
    def initialize(msg, ios_device_id)
      @ios_device_id = ios_device_id
      super(msg)
    end
  end

  class UnregisteredApp < RuntimeError; end
  class InvalidLocation < RuntimeError; end
  class CommandTimeout < RuntimeError; end
  class CommandFailure < RuntimeError; end

  # restart: flag to indicate whether to completely overwrite ssh connection
  def connect(restart: false)
    disconnect unless restart
    log_debug "connecting"
    @ssh = Net::SSH.start(@device.ip, DEVICE_USERNAME, :password => DEVICE_PASSWORD)
  end

  def disconnect
    return if @ssh.nil? || @ssh.closed?
    log_debug "closing"
    @ssh.close
  end

  # overwrite this method 
  def max_command_attempts
    IosDeviceUtilities::MAX_COMMAND_ATTEMPTS
  end

  # overwrite this method in your including class
  def unique_debug_id
    nil
  end

  # overwrite this method for custom callbacks when remote execution
  # commands fail
  def failed_remote_exec(command, resp)
    resp
  end

  # wrapper around puts that preceeds with unique id
  # for easier mulithreaded debugging
  def log_debug(msg, prefix: nil)
    prefix = prefix || unique_debug_id
    prefix = "#{prefix}: " if prefix
    puts "#{prefix}#{msg}"
  end

  def remote_exec(command, command_attempts: nil, timeout: 300)
    resp, attempt = nil, 0

    command_attempts = command_attempts || max_command_attempts

    while attempt < command_attempts
      attempt += 1

      resp = begin
        exec_result = channel_exec(command, timeout)
        exec_result = exec_result[:exit_code] == 0 ? exec_result = exec_result[:std_out] : exec_result = exec_result[:std_err]
        exec_result
      rescue Net::SSH::Disconnect, IOError, Errno::ECONNRESET, CommandTimeout, CommandFailure => e
        e
      rescue => e
        log_debug "Uncaught Error type: #{e.class} : #{e.message}"
      end

      return nil unless resp

      if [Net::SSH::Disconnect, Errno::ECONNRESET, IOError, CommandFailure].include?(resp.class)
        log_debug "#{resp.class}: restarting connection"
        connect(restart: true)
      elsif resp.class == CommandTimeout
        restart_springboard
        raise resp
      elsif resp.match(/ST Error:/)
      else
        return resp
      end

      log_debug "Retrying command #{command} after attempt #{attempt}. Command response: #{resp}" if attempt < command_attempts
    end

    failed_remote_exec(command, resp)
  end

  def channel_exec(command, timeout)
    escaped_command = command.gsub(/"/,"\\\"")
    command_with_timeout = "timeout #{timeout}s bash -c \"#{escaped_command}\""
    stdout_data = ""
    stderr_data = ""
    exit_code = nil
    exit_signal = nil
    @ssh.open_channel do |channel|
      channel.exec(command_with_timeout) do |ch, success|
        raise CommandFailure, "Error running command: #{command_with_timeout}" unless success

        channel.on_data do |ch,data|
          stdout_data+=data
        end

        channel.on_extended_data do |ch,type,data|
          stderr_data+=data
        end

        channel.on_request("exit-status") do |ch,data|
          exit_code = data.read_long
        end

        channel.on_request("exit-signal") do |ch, data|
          exit_signal = data.read_long
        end
      end
    end
    @ssh.loop
    raise CommandTimeout, "Timeout running command (124): #{command_with_timeout}" if exit_code == 124
    
    {
      :std_out => stdout_data,
      :std_err => stderr_data,
      :exit_code => exit_code
    }
  end

  def run_command(command, description, expected_output = nil, timeout: 300)
    # add additional check to ensure cycript command doesn't hang indefinitely
    is_cycript = /cycript -p (\w+)/.match(command)
    
    if is_cycript
      app_count = remote_exec "ps aux | grep #{is_cycript[1]} | grep -v grep | wc -l"
      if app_count.include?('0')
        restart_springboard
        raise "Restarted springboard: Running cycript on app #{is_cycript[1]} but app is not running or crashed." 
      end
    end

    resp = remote_exec(command, timeout: timeout)
    if expected_output != nil && resp.chomp != expected_output
      raise "Expected output #{expected_output}. Received #{resp.chomp}"
    end

    resp
  rescue CriticalDeviceError => e
    raise e
  rescue => error
    raise "Error during #{description} with command: #{command}. Message: #{error.message}"
  end

  def open_app(app, kill_existing: false)

    info = get_app_info(app)

    if kill_existing
      kill_app(app)
      sleep 1
    end

    run_command("open #{info[:bundle_id]}", "Open the #{info[:name]} app")
    sleep 1

    load_common_utilities(app)
    sleep 1.5
  end

  def load_common_utilities(app)
    run_file(app, 'common_utilities.cy', common_location: true)
  end

  def system_scp(src, dest, to_device:, folder: false)
    device_prefix = "#{DEVICE_USERNAME}@#{@device.ip}:"
    `/usr/local/bin/sshpass -p #{DEVICE_PASSWORD} scp #{'-r ' if folder}#{device_prefix unless to_device}#{src} #{device_prefix if to_device}#{dest}`
  end

  def known_command_error?(resp)
    resp.match(/Error:/)
  end

  def command_success?(resp)
    resp.match(/Success/)
  end

  def kill_app(app)
    info = get_app_info(app)
    run_command("killall #{info[:name]}", "killing #{app}")
  end

  def restart_springboard
    log('restarting springboard') if self.respond_to?('log')
    kill_app(:springboard)
    sleep(13)
    log('unlocking') if self.respond_to?('log')
    unlock_device
    sleep(2)
  end

  def unlock_device
    if @device.ios_version_fmt >= IosDevice.ios_version_to_fmt_version('10.0')
      run_file(:springboard, '3_unlock_device_ios10.cy')
    else
      run_file(:springboard, '3_unlock_device_ios9.cy')
    end
  end

  def get_app_info(app)
    info = APPS_INFO_KEY[app]
    raise UnregisteredApp unless info
    info
  end

  def template_file(filepath, contents)
    run_command(
      "pushd #{scripts_location} && echo '#{contents}' > #{filepath}",
      "templating file #{filepath}"
    )
  end

  def run_and_validate_success(app, filepath, common_location: false)
    resp = run_file(app, filepath, common_location: common_location)
    raise resp unless command_success?(resp)
    resp
  end

  # filepath relative to either common scripts or specific scripts folders
  def run_file(app, filepath, common_location: false, timeout: 300)
    info = get_app_info(app)
    path = resolve_script_path(filepath, common_location)
    run_command(
      "cycript -p #{info[:name]} #{path}",
      "Run file #{filepath} on #{info[:name]}",
      timeout: timeout
    )
  end

  # use to access @scripts_location instance variable
  def scripts_location
    raise Unconfigured unless @scripts_location
    @scripts_location
  end

  def resolve_script_path(relative_path, common_location)
    root = common_location ? SHARED_UTIL_DEST : scripts_location
    File.join(root, relative_path)
  end

  # setup where methods should expect scripts to be available on the device
  def configure_scripts_location!(device_abs_path)
    raise InvalidLocation if device_abs_path == SHARED_UTIL_DEST
    @scripts_location = device_abs_path
  end

  def configure(scripts_src_abs_path, device_dest_abs_path)
    raise InvalidLocation if device_dest_abs_path == SHARED_UTIL_DEST
    @scripts_src = scripts_src_abs_path
    @scripts_location = device_dest_abs_path
    # TODO: add validation
  end

  def setup_device_scripts
    raise Unconfigured unless @scripts_location && @scripts_src
    clean_up_scripts # clean up to ensure
    system_scp(@scripts_src, @scripts_location, to_device: true, folder: true)
    system_scp(SHARED_UTIL_SRC, SHARED_UTIL_DEST, to_device: true, folder: true)
  end

  def clean_up_scripts
    run_command("rm -rf #{@scripts_location} #{SHARED_UTIL_DEST}", 'clean up scripts')
  end

  def is_app_running?(app)
    info = get_app_info(app)
    ret = run_command(
      "ps aux | grep '#{info[:name]}$' | grep -v grep | wc -l",
      "check if #{app} is running"
    )
    ret && ret.include?('0') ? false : true
  end
end
