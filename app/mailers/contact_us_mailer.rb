class ContactUsMailer < ActionMailer::Base
  default from: "mailman@mightysignal.com"
  
  def contact_us_email(options={})
      @name = options[:name]
      @email = options[:email]
      @phone = options[:phone]
      @message = options[:message]
      mail(to: "founders@mightysignal.com", subject: 'New Contact Us Submission')
    end
end
