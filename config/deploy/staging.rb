require_relative 'mighty_deployer'

set :branch, 'angular-1'
set :rails_env, 'production'
set :bundle_without, 'scraper_only'
MightyDeployer.deploy_to([:staging])

# cap staging deploy