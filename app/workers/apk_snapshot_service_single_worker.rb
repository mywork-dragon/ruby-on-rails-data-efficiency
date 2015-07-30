class ApkSnapshotServiceSingleWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => 2, queue: :sdk_single
  
  include ApkWorker

end