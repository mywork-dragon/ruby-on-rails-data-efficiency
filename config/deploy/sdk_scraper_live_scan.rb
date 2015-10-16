require_relative 'mighty_deployer'

set :branch, 'sdk_scraper_live_scan'
set :rails_env, 'production'
MightyDeployer.deploy_to([:sdk_scraper_live_scan])
