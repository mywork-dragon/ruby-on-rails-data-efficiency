Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

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

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               'example.com',
    user_name:            'mightysignalmailman',
    password:             'iamthemailmanofmightysignalyo',
    authentication:       'plain',
    enable_starttls_auto: true  }

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000}

  config.action_dispatch.tld_length = 0

  config.env = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'env.yml'))).result)

  # The bucket to store apk pkg summary files.
  config.app_pkg_summary_bucket = "varys-apk-file-summaries-dev"
  config.app_pkg_summary_bucket_region = "us-east-1"

  # iOS summaries
  config.ios_pkg_summary_bucket = 'varys-ipa-file-summaries-dev'
  config.ios_pkg_summary_bucket_region = 'us-east-1'

  config.fb_mau_scrape_bucket = 'ms-fb-mau-scrapes-dev'
  config.google_play_scrape_data = 'ms-google-play-scrape-data-dev'

  config.ipa_bucket = 'varys-ipa-files-dev'
  config.ipa_bucket_region = 'us-east-1'

  config.itunes_scrape_bucket = 'ms-ios-scrapes-dev'
  config.ios_classification_models_bucket = 'ms-scratch'

  # Used to store snapshot data. Currently only pulls the screenshots fields
  config.app_snapshots_bucket = 'ms-scratch'

  config.application_export_bucket = 'mightysignal-applications-dev'
  config.application_publisher_export_bucket = 'ms-scratch'


  # Bucket to store feeds
  config.feed_bucket = 'ms-scratch'
  config.redshift_firehose_stream = 'no-value'

  config.log_level = :info
end
