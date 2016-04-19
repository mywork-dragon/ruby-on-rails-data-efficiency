class EmailWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :mailers

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def contact_us(lead_options)
    ContactUsMailer.contact_us_email(lead_options).deliver
  end

  def invite_user(user_id)
    user = User.find(user_id)
    UserMailer.invite_email(user).deliver
  end
  
end