require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Varys
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.encoding = "utf-8"
    config.time_zone = 'Pacific Time (US & Canada)'
    config.cache_prefix = {namespace: 'cache:varys'}

    # https://github.com/docker-library/redis/issues/45
    redis_uri = if Rails.env.development?
                  "redis://redis:6379"
                else
                  "redis://varys-production.bsqwsz.0001.use1.cache.amazonaws.com:6379"
                end
    config.cache_store = :redis_store, redis_uri, config.cache_prefix

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.autoload_paths << "#{config.root}/app/services"
    #config.autoload_paths << "#{config.root}/app/workers"
    config.autoload_paths << "#{config.root}/jobs"

    # Add all subdirectories in app/lib (note: not lib)
    Dir.glob(Rails.root.join('app/lib/**/')).each do |folder|
      config.autoload_paths << folder
    end

    #turn of auto-generation of stylesheet and Javascripts
    config.generators do |g|
      g.stylesheets     false
      g.javascripts     false
      g.test_framework  false
    end

    #cors
    # config.middleware.insert_before 0, "Rack::Cors" do
    #   allow do
    #     origins '*'
    #     resource '*', :headers => :any, :methods => [:get, :post, :options]
    #   end
    # end

    # opt into Rails 5 behavior to avoid deprecation warnings
    config.active_record.raise_in_transactional_callbacks = true

    config.paperclip_defaults = {
        :storage => :s3,
        :s3_region => 'us-east-1',
        :s3_protocol => :https,
        :s3_credentials => YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 's3_credentials.yml'))).result)
    }

    # Manually declare error responses in routes.rb
    config.exceptions_app = self.routes
    config.dark_side_json_log_path = '/tmp/sidekiq.json.log'
    config.middleware.use 'RequestIdMiddleware'
  end
end

require 'pp'
