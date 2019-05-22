# class SidekiqTesterServiceWorker
#   include Sidekiq::Worker
#
#   sidekiq_options :retry => false, queue: :scraper_master # replace with whatever you want
#
#   def perform
#     puts bid
#     puts "Done"
#   end
# end
