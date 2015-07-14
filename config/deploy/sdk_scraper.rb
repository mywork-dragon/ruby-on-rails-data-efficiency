require_relative 'mighty_deployer'

set :branch, 'sdk_scraper'
MightyDeployer.deploy_to([:sdk_scraper])
