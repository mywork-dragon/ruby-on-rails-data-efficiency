class SidekiqTesterServiceWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :kylo # replace with whatever you want

  def perform(arg)
    ap "Performing with arg #{arg}"
    sleep_time = rand(0..15)
    ap "Sleeping for #{sleep_time} seconds"
    sleep sleep_time
    ap "Done"
  end
end