class ApkSnapshotServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => 2, queue: :sdk
  
  include ApkWorker

end