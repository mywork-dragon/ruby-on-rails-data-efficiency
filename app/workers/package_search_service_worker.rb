class PackageSearchServiceWorker

  include Sidekiq::Worker

  sidekiq_options :backtrace => true, :retry => false, :queue => :sdk

  def single_queue?
    false
  end

  # expects to use Bing which has less strict ip blocking
  def proxy_type
    :all_static
  end

  include PackageSearchWorker
  
end
