require_relative 'mighty_deployer'

set :rails_env, 'production'
set :deploy_to, '/Users/darth-vader/webapps/varys'
set :bundle_without, 'development test therubyracer_js_runtime'

set :sidekiq_log, '/Users/darth-vader/sidekiq.log'
set :sidekiq_pid, '/Users/darth-vader/sidekiq.pid'

MightyDeployer.deploy_to([:darth_vader])