class FixIosCategoriesWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :default

  def perform(iacs_ids, value)
    iacs_ids.each do |iacs_id|
      iacs = IosAppsCategoriesSnapshot.find(iacs_id)
      iacs.kind = value
      iacs.save
    end
  end
  
end