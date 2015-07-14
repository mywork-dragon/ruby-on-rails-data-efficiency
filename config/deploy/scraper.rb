require_relative 'mighty_deployer'

set :branch, 'scraper'
set :rails_env, 'production'
MightyDeployer.deploy_to([:scraper])

#hello hi!!!