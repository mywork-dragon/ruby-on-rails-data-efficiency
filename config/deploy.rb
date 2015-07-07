require 'sshkit/dsl'

# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'varys'
set :repo_url, 'git@github.com:MightySignal/varys.git'

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

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
set :linked_files, %w{config/database.yml config/secrets.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :sidekiq_monit_default_hooks, false

set :sidekiq_role, :scraper
# set :sidekiq_role, [:scraper, :super_scraper]
set :scraper_processes, 25
set :super_scraper_processes, 50
set :sidekiq_log, '/home/deploy/sidekiq.log'
set :sidekiq_pid, '/home/deploy/sidekiq.pid'

# on roles(:scraper) do
#   set :sidekiq_queue, %w(old_default)
# end
#
# on roles(:super_scraper) do
#   set :sidekiq_queue, %w(critical default)
# end

set :sidekiq_queue, %w(critical default low)

set :whenever_roles, [:scraper]

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # We just need to restart web server, not app server
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web, :api), in: :groups, limit: 3, wait: 10 do
      execute "cat /home/webapps/varys/shared/unicorn.pid | xargs kill -s HUP"
    end
    
    # run bower install to get bower updates
    on roles(:web) do
      execute '(cd /home/webapps/varys/current/public/app && bower install)'
    end
  end

end