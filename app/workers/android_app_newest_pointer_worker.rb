class AndroidAppNewestPointerWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :sdk

  def perform(android_app_id)
    AndroidApp.find(android_app_id).update_newest_apk_snapshot
  end
end