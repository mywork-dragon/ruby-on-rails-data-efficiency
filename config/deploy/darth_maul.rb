require_relative 'mighty_deployer'

set :rails_env, 'production'
set :deploy_to, '/Users/darth-maul/webapps/varys'
set :bundle_without, 'development test therubyracer_js_runtime'

set :ssh_options, {
  keys: File.join(ENV['HOME'], '.ssh', 'darth-vader'),
  forward_agent: false, # not sure of correct value
  auth_methods: %w(publickey)
}

set :sidekiq_log, '/Users/darth-maul/sidekiq.log'
set :sidekiq_pid, '/Users/darth-maul/sidekiq.pid'

MightyDeployer.deploy_to([:darth_maul])
