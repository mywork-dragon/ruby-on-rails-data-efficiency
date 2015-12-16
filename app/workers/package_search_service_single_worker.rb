class PackageSearchServiceSingleWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => 2, queue: :sdk

  def single_queue?
    true
  end

  include PackageSearchWorker

  
end