class PackageSearchServiceWorker

  include Sidekiq::Worker

  sidekiq_options :backtrace => true, :retry => false, :queue => :sdk

  def single_queue?
    false
  end

  include PackageSearchWorker
  
end