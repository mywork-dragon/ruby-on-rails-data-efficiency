require_relative 'mighty_deployer'

set :rails_env, 'production'
set :bundle_without, 'scraper_only'
MightyDeployer.deploy_to([:staging])