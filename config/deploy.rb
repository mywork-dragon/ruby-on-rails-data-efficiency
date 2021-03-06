require 'sshkit/dsl'

# config valid only for Capistrano 3.1
lock '3.4.0'

# set :stages, %w(production scraper sdk_scraper web_api)
set :stages, %w(scraper sdk_scraper web staging darth_vader kylo_ren darth_maul ios_live_scan monitor sdk_scraper_live_scan aviato)

set :application, 'varys'
set :repo_url, 'git@github.com:MightySignal/varys.git'

# Default branch is :master
set :branch, ENV["MS_BRANCH"] || "master" # set in get_swole.rb

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/webapps/varys'

# By default, use the varys ssh key
set :ssh_options, {
  keys: File.join(ENV['HOME'], '.ssh', 'varys'),
  forward_agent: false, # not sure of correct value
  auth_methods: %w(publickey)
}

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, false #for sidekiq-capistrano gem

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml config/s3_credentials.yml config/env.yml config/initializers/bugsnag.rb}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :sidekiq_monit_default_hooks, false

# set :sidekiq_role, :scraper
set :sidekiq_role, [:sdk_scraper, :sdk_scraper_live_scan, :scraper_master, :scraper , :web, :darth_vader, :kylo_ren, :darth_maul, :ios_live_scan, :monitor, :aviato, :migration]
set :sidekiq_log, '/home/deploy/sidekiq.log'
set :sidekiq_pid, '/home/deploy/sidekiq.pid'

set :sdk_scraper_concurrency, 13 # 5 for DL and classification, 20 for mass google scrape
set :sdk_scraper_live_scan_concurrency, 30
set :scraper_concurrency, 25
set :scraper_master_concurrency, 50
set :web_concurrency, 5
set :darth_vader_concurrency, 10
set :kylo_ren_concurrency, 10
set :darth_maul_concurrency, 10
set :ios_live_scan_concurrency, 25
set :monitor_concurrency, 3
set :aviato_concurrency, 50
set :migration_concurrency, 3

# set :sidekiq_queue, %w(critical default low)

set :sdk_scraper_queue, %w(sdk)
set :sdk_scraper_live_scan_queue, %w(sdk_live_scan)
set :scraper_queue, %w(critical default)
set :scraper_master_queue, %w(scraper_master critical default)  #needs to go after scraper_queue definition
set :web_queue, %w(mailers)
set :darth_vader_queue, %w(ios_live_scan ios_live_scan_test)
set :kylo_ren_queue, %w(ios_epf_mass_scan ios_mass_scan)
set :darth_maul_queue, %w(maul)
set :ios_live_scan_queue, %w(ios_live_scan_cloud)
set :monitor_queue, %w(monitor)
set :aviato_queue, %w(aviato)
set :migration_queue, %w(noop)

set :whenever_roles, [:scraper, :scraper_master, :sdk_scraper, :kylo_ren, :darth_vader, :darth_maul, :sdk_scraper_live_scan, :ios_live_scan, :monitor, :aviato]

set :whenever_identifier, "#{fetch(:application)}"

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # We just need to restart web server, not app server
    end
  end

  after :published, :restart

  after :restart, :clear_cache do
    # on roles(:web, :api), in: :groups, limit: 3, wait: 10 do

    # run bower & node updates
    on roles(:web, :staging) do
      within '/home/webapps/varys/current/public/app' do
        execute(:npm, 'install', '--production')
        execute(:npm, 'run', 'bower-install')
      end
    end

    on roles(:web, :staging) do
      within '/home/webapps/varys/current' do
        execute(:npm, 'install')
        execute(:npm, 'run', 'gulp-build')
      end
    end

    # restart web server
    on roles(:web, :staging), in: :groups, limit: 3, wait: 10 do
      if test("[ -s /home/webapps/varys/shared/unicorn.pid ]")
        execute "cat /home/webapps/varys/shared/unicorn.pid | xargs kill"
      end
      within '/home/webapps/varys/current' do
        execute(:bundle, 'exec', 'unicorn_rails', '-E', 'production', '-c',
                'config/unicorn.rb', '-D')
      end
    end

    on roles(:web, :staging), in: :groups, limit: 3, wait: 10 do
      within '/home/webapps/varys/current' do
        with rails_env: :production do
          rake 'aws:register_instance'
        end
      end
    end

  end
end
