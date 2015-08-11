class ApkSnapshotServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => false, queue: :sdk
  
  include ApkWorker

end