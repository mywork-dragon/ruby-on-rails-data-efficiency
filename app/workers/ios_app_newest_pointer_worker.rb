class IosAppNewestPointerWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :sdk

  def perform(ios_app_id)
    IosApp.find(ios_app_id).update_newest_ipa_snapshot
  end
end