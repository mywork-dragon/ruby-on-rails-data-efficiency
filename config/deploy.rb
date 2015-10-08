require 'sshkit/dsl'

# config valid only for Capistrano 3.1
lock '3.2.1'

# set :stages, %w(production scraper sdk_scraper web_api)
set :stages, %w(production scraper sdk_scraper sdk_scraper_dev web staging)
set :default_stage, 'production'

set :application, 'varys'
set :repo_url, 'git@github.com:MightySignal/varys.git'

# Default branch is :master
# set :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/webapps/varys'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, false #for sidekiq-capistrano gem

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml config/s3_credentials.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :sidekiq_monit_default_hooks, false

# set :sidekiq_role, :scraper
set :sidekiq_role, [:sdk_scraper, :sdk_scraper_master, :scraper, :scraper_master, :web, :sdk_scraper_dev]
set :sidekiq_log, '/home/deploy/sidekiq.log'
set :sidekiq_pid, '/home/deploy/sidekiq.pid'

set :sdk_scraper_concurrency, 30
set :scraper_master_concurrency, 50
set :scraper_concurrency, 50
set :web_concurrency, 1

# set :sidekiq_queue, %w(critical default low)

set :sdk_scraper_queue, %w(sdk)
set :scraper_master_queue, %w(critical scraper_master default low)
set :scraper_queue, %w(critical default low)
set :web_queue, %w(no_op)

set :whenever_roles, [:scraper, :sdk_scraper, :sdk_scraper_dev]

set :whenever_identifier, "#{fetch(:application)}"

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # We just need to restart web server, not app server
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    # on roles(:web, :api), in: :groups, limit: 3, wait: 10 do

    on roles(:web, :staging), in: :groups, limit: 3, wait: 10 do
      execute "cat /home/webapps/varys/shared/unicorn.pid | xargs kill -s HUP"
    end

    # run bower install to get bower updates
    on roles(:web, :staging) do
      execute '(cd /home/webapps/varys/current/public/app && bower install)'
    end
  end

end