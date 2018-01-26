class ApkSnapshotCleanupWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :apk_snapshot_cleanup

  def perform(ids)
    ids.each |id|
      AndroidApp::validate_snapshot_history(id)
    end
  end

end
