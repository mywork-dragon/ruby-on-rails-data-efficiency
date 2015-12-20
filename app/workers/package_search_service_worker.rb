class PackageSearchServiceWorker

  MAX_CONCURRENT_DOWNLOADS = 10

  class << self
    attr_accessor :concurrent_downloads
  end

  include Sidekiq::Worker

  sidekiq_options :backtrace => true, :retry => false, :queue => :sdk

  def single_queue?
    false
  end

  # def wait_for_open_download_spot
  #   private_ip = ip

  #   # ooh an infinite loop!
  #     while true
  #       sdk_scraper = SdkScraper.find_by_private_ip(private_ip)

  #       if sdk_scraper.concurrent_apk_downloads < MAX_CONCURRENT_DOWNLOADS
  #         sdk_scraper.concurrent_apk_downloads += 1
  #         sdk_scraper.save
  #         break
  #       end

  #       sleep(rand(0.5..2.0)) # sleep for a random time
  #     end
  # end

  def wait_for_open_download_spot

    # ooh an infinite loop!
      while true

        if `ls -1 /home/deploy/threads | wc -l`.strip.to_i < MAX_CONCURRENT_DOWNLOADS
          `touch /home/deploy/threads/t#{@snap_id}`
          break
        end

        sleep(rand(0.5..2.0)) # sleep for a random time
      end
  end

  def decrement_concurrent_downloads
    `rm /home/deploy/threads/t#{@snap_id}`
  end

  def thread_file
  end

  def ip
    `hostname -I`.strip
  end


  include PackageSearchWorker
  
end