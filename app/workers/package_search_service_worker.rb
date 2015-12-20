class PackageSearchServiceWorker

  MAX_CONCURRENT_DOWNLOADS = 10

  @concurrent_downloads = 0

  class << self
    attr_accessor :concurrent_downloads
  end

  include Sidekiq::Worker

  sidekiq_options :backtrace => true, :retry => false, :queue => :sdk

  def single_queue?
    false
  end

  def wait_for_open_download_spot
    # ooh an infinite loop!
      while true

        if self.class.concurrent_downloads < MAX_CONCURRENT_DOWNLOADS
          self.class.concurrent_downloads += 1
          break
        end

        sleep(rand(0.1..0.125)) # sleep for a random time
      end
  end

  def decrement_concurrent_downloads
    self.class.concurrent_downloads -= 1
  end


  include PackageSearchWorker
  
end