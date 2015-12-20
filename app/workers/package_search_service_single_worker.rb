class PackageSearchServiceSingleWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => 2, queue: :sdk

  def single_queue?
    true
  end

  # no-op
  def wait_for_open_download_spot
  end

  # no-op
  def decrement_current_downloads
  end

  include PackageSearchWorker

  
end