require_relative 'mighty_deployer'

set :branch, 'staging'
set :rails_env, 'production'
MightyDeployer.deploy_to([:staging])