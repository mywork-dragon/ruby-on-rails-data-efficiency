class TestServiceWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sdk

  def perform()

  end

end