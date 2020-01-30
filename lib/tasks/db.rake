# Avoid harming production DB when using Cloud9. Inspired on an incident.

if Rails.env == 'production' || ENV['RAILS_ENV'] == 'production' || Rails.env.production?
  tasks = Rake.application.instance_variable_get '@tasks'
  
  tasks.delete 'db:reset'
  tasks.delete 'db:drop'
  tasks.delete 'db:drop:all'
  tasks.delete 'db:seed'
  tasks.delete 'db:setup'
  tasks.delete 'db:create'
  tasks.delete 'db:create:all'
  tasks.delete 'db:schema:dump'
  tasks.delete 'db:schema:load'
  tasks.delete 'db:migrate:redo'
  tasks.delete 'db:structure:load'
  tasks.delete 'db:structure:dump'
  
  namespace :db do
    task :reset do
      puts '####### PRODUCTION!!! db:reset has been disabled'
    end
    task :drop do
      puts '####### PRODUCTION!!! db:drop has been disabled'
    end
    task :create do
      puts '####### PRODUCTION!!! db:create has been disabled'
    end
    task :setup do
      puts '####### PRODUCTION!!! db:setup has been disabled'
    end
    task :seed do
      puts '####### PRODUCTION!!! db:seed has been disabled'
    end
    namespace :create do
      desc 'Overrides the `db:schema:load` rake  in order to load legacy schema before running the default `db:schema:load` task'
      task all: [:load_config, :environment] do
        puts '####### PRODUCTION!!! db:create:all has been disabled'
      end
    end
    namespace :drop do
      desc 'Overrides the `db:schema:load` rake  in order to load legacy schema before running the default `db:schema:load` task'
      task all: [:load_config, :environment] do
        puts '####### PRODUCTION!!! db:drop:all has been disabled'
      end
    end
    namespace :migrate do
      task :redo do
        puts '####### PRODUCTION!!! db:migrate:redo has been disabled'
      end
    end
    namespace :schema do
      task load: [:load_config, :environment] do
        puts '####### PRODUCTION!!! db:schema:load has been disabled'
      end
      task dump: [:load_config, :environment] do
        puts '####### PRODUCTION!!! db:schema:dump has been disabled'
      end
    end
    namespace :structure do
      task load: [:load_config, :environment] do
        puts '####### PRODUCTION!!! db:structure:load has been disabled'
      end
      task dump: [:load_config, :environment] do
        puts '####### PRODUCTION!!! db:structure:dump has been disabled'
      end
    end
  end
  
end