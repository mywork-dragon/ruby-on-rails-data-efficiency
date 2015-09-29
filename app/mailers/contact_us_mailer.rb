class ContactUsMailer < ActionMailer::Base
  default from: "mailman@mightysignal.com"
  
  def contact_us_email(options={})
      @first_name = options[:first_name]
      @last_name = options[:last_name]
      @company = options[:company]
      @email = options[:email]
      @phone = options[:phone]
      @crm = options[:crm]
      @sdk = options[:sdk]
      @message = options[:message]
      mail(to: "founders@mightysignal.com", bcc: "h1p1t0g3w9o9d5j9@mightysignal.slack.com", reply_to: @email, subject: 'MightySignal Interest')
  end
  
end
