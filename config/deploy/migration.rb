require_relative 'mighty_deployer'

set :rails_env, 'production'
MightyDeployer.deploy_to([:migration])
