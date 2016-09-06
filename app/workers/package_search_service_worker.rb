class PackageSearchServiceWorker

  # MAX_CONCURRENT_DOWNLOADS = 10

  include Sidekiq::Worker

  sidekiq_options :backtrace => true, :retry => false, :queue => :sdk

  def single_queue?
    false
  end

  def proxy_type
    :android_classification
  end

  include PackageSearchWorker
  
end
