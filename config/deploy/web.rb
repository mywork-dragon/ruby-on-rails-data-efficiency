require_relative 'mighty_deployer'

set :branch, 'master'
set :rails_env, 'production'
# MightyDeployer.deploy_to([:web_api])
MightyDeployer.deploy_to([:web])