require_relative 'mighty_deployer'

set :rails_env, 'production'
set :deploy_to, '/Users/kylo-ren/webapps/varys'
set :bundle_without, 'development test therubyracer_js_runtime'

set :sidekiq_log, '/Users/kylo-ren/sidekiq.log'
set :sidekiq_pid, '/Users/kylo-ren/sidekiq.pid'

MightyDeployer.deploy_to([:kylo_ren])