class EmailWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :mailers

  def perform(lead_options)
    ContactUsMailer.contact_us_email(lead_options).deliver
  end
  
end