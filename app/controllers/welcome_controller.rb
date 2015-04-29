class WelcomeController < ApplicationController
  
  protect_from_forgery except: :contact_us
  
  def index
    
  end
  
  def contact_us
    first_name = params['first_name']
    last_name = params['last_name']
    email = params['email']
    company = params['company']
    phone = params['phone']
    crm = params['crm']
    sdk = params['sdk']
    message = params['message']
    
    lead_options = params.slice(:first_name, :last_name, :company, :email, :phone, :crm, :sdk, :message).merge({lead_source: "Web"})
    
    if company.blank?
      email_regex = /@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
      lead_options[:company] = email.match(email_regex).to_s[1..-1]
    end
    
    begin
      MightySignalSalesforceService.create_lead(lead_options)  #temp out as SF is down
    rescue => e
      
    end
    
    ContactUsMailer.contact_us_email(lead_options).deliver
    
    redirect_to action: :index
  end
  
end
