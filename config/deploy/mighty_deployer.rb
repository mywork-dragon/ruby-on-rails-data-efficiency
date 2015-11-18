module MightyDeployer

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
  @ios_live_scan_roles = []
  
  @web_servers = []
  # @api_servers = []
  @staging_servers = []
  @scraper_servers = []
  @sdk_scraper_servers = []
  @sdk_scraper_live_scan_servers = []
  @darth_vader_servers = []
  @ios_live_scan_servers = []

  def self.deploy_to(server_symbols)
    valid_symbols = [:web, :scraper, :sdk_scraper, :sdk_scraper_live_scan, :darth_vader, :staging, :ios_live_scan]
    
    raise "Input an array with a combination of these values: #{valid_symbols}" unless (server_symbols - valid_symbols).empty?
    
    define_web_servers if server_symbols.include?(:web)
    define_scraper_servers if server_symbols.include?(:scraper)
    define_sdk_scraper_servers if server_symbols.include?(:sdk_scraper)
    define_sdk_scraper_live_scan_servers if server_symbols.include?(:sdk_scraper_live_scan)
    define_staging_servers if server_symbols.include?(:staging)
    define_darth_vader_servers if server_symbols.include?(:darth_vader)
    define_ios_live_scan_servers if server_symbols.include?(:ios_live_scan)
    
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
    @darth_vader_servers = %w(
      192.168.1.4
    )

    @app_roles += @darth_vader_servers
    @darth_vader_roles += @darth_vader_servers
  end

  def self.define_ios_live_scan_servers
    @ios_live_scan_servers = %w(
      54.173.117.185
    )
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
    role :ios_live_scan, @ios_live_scan_roles
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

    @ios_live_scan_servers.each do |ios_live_scan_server|
      server ios_live_scan_server, user: 'deploy'
    end
    
  end


  
end