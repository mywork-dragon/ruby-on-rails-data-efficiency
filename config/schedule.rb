# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

env :PATH, ENV['PATH']

set :output, "/home/deploy/cron.log"

#this works! keep as a sample
# every 1.minutes, roles: [:scraper] do
#   runner "SidekiqTester.say_hi"
# end

every :day, :at => '6:00am', roles: [:migration] do
  command 'cat /dev/null > /home/deploy/cron.log'
end

every :day, :at => '6:05am', roles: [:migration] do
  command 'cat /dev/null > /home/deploy/sidekiq.log'
end

# delete old snapshot files older than 1 day on the dark-side machines
every :day, :at => '9:00am', roles: [:kylo_ren, :darth_vader, :darth_maul] do
  runner "IosMonitorService.delete_old_classdumps", :output => '/var/log/varys/cron.log'
end

every :week, :at => '12:05am', roles: [:kylo_ren, :darth_vader] do
  command 'cat /dev/null > /var/log/varys/sidekiq.log', :output => '/var/log/varys/cron.log'
  command 'cat /dev/null > /var/log/varys/sidekiq.json.log', :output => '/var/log/varys/cron.log'
end

every :month, roles: [:kylo_ren, :darth_vader] do
  command 'cat /dev/null > /var/log/varys/fluentd.out', :output => '/var/log/varys/cron.log'
  command 'cat /dev/null > /var/log/varys/fluentd.err', :output => '/var/log/varys/cron.log'
  command 'cat /dev/null > /var/log/varys/cron.log', :output => '/var/log/varys/cron.log'
end

every 30.minutes, roles: [:kylo_ren] do
  rake "dark_side:mass_tunnel", :output => '/var/log/varys/cron.log'
end


every 2.hours, roles: [:kylo_ren] do # every 2 hours
  runner "IosFbAdService.begin_scraping", :output => '/var/log/varys/cron.log'
end

every "0 1,3,5,7,9,11,13,15,17,19,21,23 * * *", roles: [:kylo_ren] do # every 2 hours at the 30 minute mark
  runner "IosFbCleaningService.clean_devices", :output => '/var/log/varys/cron.log'
end

############################################
# scheduler container runs in UTC
############################################
#
every :day, :at => '7:56am', roles: [:varys_scheduler] do
  runner 'EpfV2Worker.new.run_epf_if_feed_available', :output => '/var/log/cron.log'
end

every :day, at: '1:00am', roles: [:varys_scheduler] do
  runner 'AndroidSdk.store_current_sdks_in_s3', :output => '/var/log/cron.log'
end

every :day, at: '2:00am', roles: [:varys_scheduler] do
  runner 'GooglePlayChartScraperService.scrape_google_play_top_free', :output => '/var/log/cron.log'
end

every :day, at: '2:30am', roles: [:varys_scheduler] do
  runner 'ItunesChartService.run_itunes_top_free', :output => '/var/log/cron.log'
end

every :day, at: '3:00pm', roles: [:varys_scheduler] do
  runner "ItunesTosWorker.check_app_stores", :output => '/var/log/cron.log'
end

every :day, at: '3:00pm', roles: [:varys_scheduler] do
  runner 'CustomerHappinessService.pull_mixpanel_data', :output => '/var/log/cron.log'
end

every :wednesday, :at => '8:00am', roles: [:varys_scheduler] do
  runner 'ElasticSearchWorker.perform_async(:update_ios)', :output => '/var/log/cron.log'
end

every :day, at: '3:00am', roles: [:varys_scheduler] do
  runner 'GooglePlayChartService.run_gplay_top_free', :output => '/var/log/cron.log'
end

every :day, at: '4:00am', roles: [:varys_scheduler] do
  runner 'FbMauScrapeWorker.scrape_all', :output => '/var/log/cron.log'
end
