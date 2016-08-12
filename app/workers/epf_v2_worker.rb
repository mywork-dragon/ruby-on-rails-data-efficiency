class EpfV2Worker
  include Sidekiq::Worker
  sidekiq_options queue: :scraper_master, retry: false

  def perform(method_name, *args)
    EpfV2Service.new.send(method_name, *args)
  end
end
