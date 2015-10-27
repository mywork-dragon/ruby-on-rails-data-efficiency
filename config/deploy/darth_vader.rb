require_relative 'mighty_deployer'

set :rails_env, 'production'
set :deploy_to, '/Users/darth-vader/webapps/varys'
set :bundle_without, 'development test therubyracer_js_runtime'
MightyDeployer.deploy_to([:darth_vader])