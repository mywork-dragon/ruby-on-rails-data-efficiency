class SidekiqTesterServiceWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :default # replace with whatever you want

  def perform()
    ap "Done"
  end
end