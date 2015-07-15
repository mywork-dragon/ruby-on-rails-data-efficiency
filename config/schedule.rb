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

# 2.times do |i|
#   every 1.day, :at => '1:00am' do
#     rake "scraper:scrape_all SCRAPE_PROCESSES=1 SCRAPE_PAGE_NUMBER=#{i}"
#   end
# end
