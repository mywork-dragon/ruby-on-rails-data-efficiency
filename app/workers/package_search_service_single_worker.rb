class PackageSearchServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => 2, queue: :sdk_live_scan

  def single_queue?
    true
  end

  include PackageSearchWorker

  
end