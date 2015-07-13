require_relative 'mighty_deployer'

MightyDeployer.deploy_to([:web_api, :scraper, :sdk_scraper])