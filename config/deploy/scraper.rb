require_relative 'mighty_deployer'

set :branch, 'scraper'
MightyDeployer.deploy_to([:scraper])

#HERRO