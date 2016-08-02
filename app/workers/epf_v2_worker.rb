class EpfV2Worker
  include Sidekiq::Worker
  sidekiq_options queue: :aviato, retry: false

  def perform(method_name, *args)
    EpfV2Service.new.send(method_name, *args)
  end
end
