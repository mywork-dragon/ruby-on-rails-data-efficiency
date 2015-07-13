require_relative 'mighty_deployer'

set :branch, 'master'
MightyDeployer.deploy_to([:web_api, :scraper, :sdk_scraper])