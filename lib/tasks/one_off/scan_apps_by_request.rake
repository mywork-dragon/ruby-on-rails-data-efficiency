# require '/varys/app/workers/contacts_import/contacts_import_worker'
require_relative './one_off_app_scanner'

desc 'Scan apps from a csv file provided by customer'
task :scan_apps_by_request => [:environment] do
  logger           = Logger.new(STDOUT)
  logger.level     = Logger::DEBUG
  Rails.logger     = logger
  OneOffAppScanner.process_file 'location_apps.csv'
end