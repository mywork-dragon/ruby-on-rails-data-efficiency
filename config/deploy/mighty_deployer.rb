require 'json'

module MightyDeployer

  MIGHTY_SIGNAL_PUBLIC_IP = '173.247.196.70'

  @app_roles = []
  @web_roles = []
  # @api_roles = []
  @staging_roles = []
  @db_roles = []
  @sdk_scraper_roles = []
  @sdk_scraper_live_scan_roles = []
  @scraper_roles = []
  @scraper_master_role = nil
  @darth_vader_roles = []
  @kylo_ren_roles = []
  @ios_live_scan_roles = []
  @monitor_roles = []
  @aviato_roles = []
  
  @web_servers = []
  # @api_servers = []
  @staging_servers = []
  @scraper_servers = []
  @sdk_scraper_servers = []
  @sdk_scraper_live_scan_servers = []
  @darth_vader_servers = []
  @kylo_ren_servers = []
  @ios_live_scan_servers = []
  @monitor_servers = []
  @aviato_servers = []

  def self.deploy_to(server_symbols)
    valid_symbols = [:web, :scraper, :sdk_scraper, :sdk_scraper_live_scan, :darth_vader, :kylo_ren, :staging, :ios_live_scan, :monitor, :aviato]
    
    raise "Input an array with a combination of these values: #{valid_symbols}" unless (server_symbols - valid_symbols).empty?
    
    define_web_servers if server_symbols.include?(:web)
    define_scraper_servers if server_symbols.include?(:scraper)
    define_sdk_scraper_servers if server_symbols.include?(:sdk_scraper)
    define_sdk_scraper_live_scan_servers if server_symbols.include?(:sdk_scraper_live_scan)
    define_staging_servers if server_symbols.include?(:staging)
    define_darth_vader_servers if server_symbols.include?(:darth_vader)
    define_kylo_ren_servers if server_symbols.include?(:kylo_ren)
    define_ios_live_scan_servers if server_symbols.include?(:ios_live_scan)
    define_monitor_servers if server_symbols.include?(:monitor)
    define_aviato_servers if server_symbols.include?(:aviato)
    
    define_roles
    
    set_users
  end

  def self.define_web_servers
    @web_servers = %w(
      54.85.3.24
    )

    # @api_servers = %w(
    #   52.6.191.250
    # )
  
    # @app_roles += @web_servers + @api_servers
    @app_roles += @web_servers
    @web_roles += @web_servers
    @db_roles += @web_servers
    # @api_roles += @api_servers
  
  end

  def self.define_scraper_servers
    @scraper_servers = %w(
      52.3.11.3
      52.2.56.165
      52.2.60.230
      52.2.124.31
      52.3.159.84
    )
    
    @scraper_master_role = @scraper_servers.first
  
    @app_roles += @scraper_servers
    @scraper_roles += @scraper_servers
  end

  def self.define_sdk_scraper_servers
    @sdk_scraper_servers = %w(
      54.88.39.109
      54.86.80.102
      54.210.56.58
      54.210.55.23
    )

    @app_roles += @sdk_scraper_servers
    @sdk_scraper_roles += @sdk_scraper_servers
  end

  def self.define_sdk_scraper_live_scan_servers
    @sdk_scraper_live_scan_servers = %w(
        54.164.24.87
      )

    @app_roles += @sdk_scraper_live_scan_servers
    @sdk_scraper_live_scan_roles += @sdk_scraper_live_scan_servers
  end

  def self.define_staging_servers
    @staging_servers = %w(
      52.7.134.183
    )

    @app_roles += @staging_servers
    @staging_roles += @staging_servers
  end

  def self.define_darth_vader_servers
    @darth_vader_servers = if inside_mighty_signal_network?
      %w(
        192.168.2.101
      )
    else
      [
        "#{MIGHTY_SIGNAL_PUBLIC_IP}:50000"
      ]
    end

    @app_roles += @darth_vader_servers
    @darth_vader_roles += @darth_vader_servers
  end

  def self.define_kylo_ren_servers
    @kylo_ren_servers = if inside_mighty_signal_network?
      %w(
        192.168.2.102
      )
    else
      [
        "#{MIGHTY_SIGNAL_PUBLIC_IP}:50001"
      ]
    end

    @app_roles += @kylo_ren_roles
    @kylo_ren_roles += @kylo_ren_servers
  end

  def self.define_ios_live_scan_servers
    @ios_live_scan_servers = %w(
      54.173.117.185
    )

    @app_roles += @ios_live_scan_servers
    @ios_live_scan_roles += @ios_live_scan_servers
  end

  def self.define_monitor_servers
    @monitor_servers = %w(
      54.88.95.195
    )

    @app_roles += @monitor_servers
    @monitor_roles += @monitor_servers
  end

  def self.define_aviato_servers
    @aviato_servers = %w(
      54.172.182.43
    )

    @app_roles += @aviato_servers
    @aviato_roles += @aviato_servers
  end

  private

  def self.define_roles
    role :app, @app_roles
    role :web, @web_roles
    # role :api, @api_roles
    role :db,  @db_roles #must have this do migrate db
    role :sdk_scraper, @sdk_scraper_roles
    role :sdk_scraper_live_scan, @sdk_scraper_live_scan_roles
    role :scraper, @scraper_roles
    role :scraper_master, @scraper_master_role
    role :staging, @staging_roles
    role :darth_vader, @darth_vader_roles
    role :kylo_ren, @kylo_ren_roles
    role :ios_live_scan, @ios_live_scan_roles
    role :monitor, @monitor_roles
    role :aviato, @aviato_roles
  end
  
  def self.set_users
    @web_servers.each do |web_server|
      server web_server, user: 'deploy'
    end
    
    # @api_servers.each do |api_server|
    #   server api_server, user: 'deploy'
    # end
    
    @scraper_servers.each do |scraper_server|
      server scraper_server, user: 'deploy'
    end
    
    @sdk_scraper_servers.each do |sdk_scraper_server|
      server sdk_scraper_server, user: 'deploy'
    end

    @sdk_scraper_live_scan_servers.each do |sdk_scraper_live_scan_server|
      server sdk_scraper_live_scan_server, user: 'deploy'
    end

    @staging_servers.each do |staging_server|
      server staging_server, user: 'deploy'
    end

    @darth_vader_servers.each do |darth_vader_server|
      server darth_vader_server, user: 'darth-vader'
    end

    @kylo_ren_servers.each do |kylo_ren_server|
      server kylo_ren_server, user: 'kylo-ren'
    end

    @ios_live_scan_servers.each do |ios_live_scan_server|
      server ios_live_scan_server, user: 'deploy'
    end

    @monitor_servers.each do |monitor_server|
      server monitor_server, user: 'deploy'
    end

    @aviato_servers.each do |aviato_server|
      server aviato_server, user: 'deploy'
    end
    
  end

  def self.inside_mighty_signal_network?
    resp = `curl -s -m 15 ipv4.wtfismyip.com/json`
    resp_json = JSON.load(resp)
    ip = resp_json['YourFuckingIPAddress'].strip
    ip == MIGHTY_SIGNAL_PUBLIC_IP
  end
  
end