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

set :output, "/home/deploy/cron.log"

#this works! keep as a sample
# every 1.minutes, roles: [:scraper] do
#   runner "SidekiqTester.say_hi"
# end

every :day, :at => '6:00am', roles: [:scraper, :sdk_scraper] do
  command 's3cmd put /home/deploy/cron.log s3://varys-backup/cron_logs/cron_"`hostname -I`"_` date +\'%Y_%m_%d_%H_%M_%S\' `.log; cat /dev/null > /home/deploy/cron.log'
end

every :day, :at => '6:05am', roles: [:scraper, :sdk_scraper, :sdk_scraper_live_scan, :ios_live_scan] do
  command 's3cmd put /home/deploy/sidekiq.log s3://varys-backup/sidekiq_logs/sidekiq_"`hostname -I`"_` date +\'%Y_%m_%d_%H_%M_%S\' `.log; cat /dev/null > /home/deploy/sidekiq.log'
end

# delete old snapshot files older than 1 day on the dark-side machines
every :day, :at => '9:00am', roles: [:kylo_ren, :darth_vader] do
  runner "IosMonitorService.delete_old_classdumps", :output => '/var/log/varys/cron.log'
end

every 6.hours, roles: [:kylo_ren] do
  rake 'fb:simulate', :output => '/var/log/varys/cron.log'
end

every 30.minutes, roles: [:kylo_ren] do
  rake "dark_side:mass_tunnel", :output => '/var/log/varys/cron.log'
end

every :day, :at => '11:56pm', roles: [:scraper_master] do
  runner 'EpfService.run_itunes_current_if_new_feed_available'
end

# every :wednesday, at: '11:55am', roles: [:scraper_master] do
#   notes = DateTime.now.strftime("%m/%d/%Y %I:%M%p")
#   runner "AppStoreSnapshotService.run('#{notes}')"
# end

# 2.times do |i|
#   every 1.day, :at => '1:00am' do
#     rake "scraper:scrape_all SCRAPE_PROCESSES=1 SCRAPE_PAGE_NUMBER=#{i}"
#   end
# end
