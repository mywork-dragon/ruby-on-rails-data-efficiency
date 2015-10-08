class IosClassServiceWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sdk

  def perform(app_id)

  end

end