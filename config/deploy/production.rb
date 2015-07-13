require_relative 'mighty_deployer'

MightyDeploy.deploy_to([:web_api, :scraper, :sdk_scraper])