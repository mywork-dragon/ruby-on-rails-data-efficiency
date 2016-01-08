class SidekiqTesterServiceWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :kylo

  def perform(arg)
    ap "Performing with arg #{arg}"
  end
end