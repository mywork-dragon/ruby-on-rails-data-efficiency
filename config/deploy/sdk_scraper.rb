require_relative 'mighty_deployer'

set :branch, 'sdk_scraper'
set :rails_env, 'production'
MightyDeployer.deploy_to(:web_api, :scraper, :sdk_scraper])