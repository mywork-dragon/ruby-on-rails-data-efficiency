class WebsiteProcessingWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :developer_linking

  def perform(method, *args)
    send(method, *args)
  end

  def backfill_helpers(website_id)
    website = Website.find(website_id)
    website.populate_helper_fields
    website.save!
  end
end
