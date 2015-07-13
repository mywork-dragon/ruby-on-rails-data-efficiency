module MightyDeployer

  @app_roles = []
  @web_roles = []
  @api_roles = []
  @db_roles = []
  @sdk_scraper_roles = []
  @scraper_roles = []

  puts "laksfnlaknsflkansfklansf!!!!"

  def test
  end

  def define_web_api_servers
    web_server = '54.85.3.24'

    api_server = '52.6.191.250'
    
    server web_server, user: 'deploy'

    server api_server, user: 'deploy'
    
    @app_roles += [web_server, api_server]
    @web_roles << web_server
    @db_roles << web_server
    @api_roles << api_server
    
  end
  
  def define_scraper_servers
    scraper_servers = %w(
      52.2.192.44
    )
    
    role :scraper, scraper_servers

    scraper_servers.each do |scraper_server|
      server scraper_server, user: 'deploy'
    end
    
    @app_roles += scraper_servers
    @scraper_roles += scraper_servers
  end
  
  def define_sdk_scraper_servers
    sdk_scraper_servers = %w(
      54.164.24.87
      54.88.39.109
      54.86.80.102
    )
    
    role :sdk_scraper, sdk_scraper_servers
    
    sdk_scraper_servers.each do |sdk_scraper_server|
      server sdk_scraper_server, user: 'deploy'
    end
    
    @app_roles += sdk_scraper_servers
    @sdk_scraper_roles += sdk_scraper_servers
  end
  
  def define_roles
    role :app, @app_roles
    role :web, @web_roles
    role :api, @api_roles
    role :db,  @db_roles #must have this do migrate db
    role :sdk_scraper, @sdk_scraper_roles
    role :scraper, @scraper_roles
  end
  
end