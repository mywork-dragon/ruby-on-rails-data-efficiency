require_relative 'mighty_deployer'

puts "WHOOOOOO".red

set :rails_env, 'production'
MightyDeployer.deploy_to([:ios_live_scan])