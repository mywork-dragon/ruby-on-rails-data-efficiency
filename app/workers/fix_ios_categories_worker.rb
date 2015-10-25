class FixIosCategoriesWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :default

  def perform(iacs_id, value)
    iacs = IosAppsCategoriesSnasphots.find(iacs_id)
    iacs.kind = value
    iacs.save
  end
  
end