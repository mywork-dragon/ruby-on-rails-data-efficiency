class ApkSnapshotServiceSingleWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => false, queue: :sdk_single
  
  include ApkWorker

end