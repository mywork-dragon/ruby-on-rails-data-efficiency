class ContactUsMailer < ActionMailer::Base
  default from: "mailman@mightysignal.com"
  
  def contact_us_email(options={})
    options = options.with_indifferent_access
    @first_name = options[:first_name]
    @last_name = options[:last_name]
    @company = options[:company]
    @email = options[:email]
    @phone = options[:phone]
    @crm = options[:crm]
    @message = options[:message]
    @ad_source = options[:ad_source]
    @creative = options[:creative]
    @web_form_button_id = options[:web_form_button_id]
    @utm_source = options[:utm_source]
    @utm_medium = options[:utm_medium]
    @utm_campaign = options[:utm_campaign]
    mail(to: "founders@mightysignal.com", bcc: "h1p1t0g3w9o9d5j9@mightysignal.slack.com", reply_to: @email, subject: 'MightySignal Interest')
  end
  
end