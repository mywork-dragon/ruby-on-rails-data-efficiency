Rails.application.configure do

  # AWS.eager_autoload! #stephen

  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_files = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  if ENV['LOG_LEVEL']
    config.log_level = ENV['LOG_LEVEL'].downcase.to_sym
  end


  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  # config.log_formatter = ::Logger::Formatter.new
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    {
      request_id: event.payload[:request_id],
      params: event.payload[:params],
      headers: event.payload[:headers],
    }
  end

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              ENV['SES_HOST'].to_s,
    port:                 ENV['SES_PORT'].to_i,
    user_name:            ENV['SES_USER'].to_s,
    password:             ENV['SES_SECRET'].to_s,
    authentication:       :login,
    enable_starttls_auto: true  }

  config.env = YAML.load_file("#{Rails.root}/config/env.yml")

  # The bucket to store apk pkg summary files.
  config.app_pkg_summary_bucket = "varys-apk-file-summaries"
  config.app_pkg_summary_bucket_region = "us-east-1"

  # iOS summaries
  config.ios_pkg_summary_bucket = 'varys-ipa-file-summaries'
  config.ios_pkg_summary_bucket_region = 'us-east-1'

  config.fb_mau_scrape_bucket = 'ms-fb-mau-scrapes'
  config.google_play_scrape_data = 'ms-google-play-scrape-data'

  config.ipa_bucket = 'varys-ipa-files'
  config.ipa_bucket_region = 'us-east-1'

  config.itunes_scrape_bucket = 'ms-ios-scrapes'
  config.ios_classification_models_bucket = 'ms-ios-classification'

  # Used to store snapshot data. Currently only pulls the screenshots fields
  config.app_snapshots_bucket = 'ms-app-snapshots'

  config.application_export_bucket = 'mightysignal-applications'
  config.application_publisher_export_bucket = 'mightysignal-application-publishers'

  # this value is also hard-coded in schedule.rb for log rotation
  config.dark_side_json_log_path = '/var/log/varys/sidekiq.json.log'

  # Bucket to store feeds
  config.feed_bucket = 'mightysignal-feeds'
  config.redshift_firehose_stream = 'redshift-ingestion'
end
