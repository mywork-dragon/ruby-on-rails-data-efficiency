class SidekiqTesterServiceWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :kylo # replace with whatever you want

  def perform(arg)
    ap "Performing with arg #{arg}"
  end
end