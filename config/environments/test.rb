Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_files = false
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  config.active_support.test_order = :sorted

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.env = YAML.load_file("#{Rails.root}/config/env.yml")

  # The bucket to store apk pkg summary files.
  config.app_pkg_summary_bucket = "varys-apk-file-summaries-dev"
  config.app_pkg_summary_bucket_region = "us-east-1"

  # iOS summaries
  config.ios_pkg_summary_bucket = 'varys-ipa-file-summaries-dev'
  config.ios_pkg_summary_bucket_region = 'us-east-1'

  config.fb_mau_scrape_bucket = 'ms-fb-mau-scrapes-dev'

  config.paperclip_defaults = {}

  config.logger = Logger.new(STDOUT)

  config.log_level = :error

  config.google_play_scrape_data = 'ms-google-play-scrape-data-dev'

  config.ipa_bucket = 'varys-ipa-files-dev'
  config.ipa_bucket_region = 'us-east-1'

  config.itunes_scrape_bucket = 'ms-ios-scrapes-dev'
  config.ios_classification_models_bucket = 'ms-scratch'
  config.redshift_firehose_stream = 'no-value'
end
