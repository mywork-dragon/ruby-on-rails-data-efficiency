class SidekiqDarthServiceWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :darth # replace with whatever you want

  def perform(arg)
    ap "Performing with arg #{arg}"
    sleep_time = rand(0..3)
    ap "Sleeping for #{sleep_time} seconds"
    sleep sleep_time
    ap "Done"
  end
end