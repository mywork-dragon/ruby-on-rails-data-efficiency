require_relative 'mighty_deployer'

set :branch, 'master'
set :rails_env, 'production'
set :bundle_without, 'scraper_only'
# MightyDeployer.deploy_to([:web_api])
MightyDeployer.deploy_to([:web])