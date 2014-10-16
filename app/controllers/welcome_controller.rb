class WelcomeController < ApplicationController
  
  def index
    
  end
  
  def team
    
  end
  
  def contact_us
    name = params['name']
    email = params['email']
    phone = params['phone']
    message = params['message']
    
    ContactUsMailer.contact_us_email(name: name, email: email, phone: phone, message: message).deliver
    
    redirect_to action: :index
  end
  
  def try_it_out
    @url = params[:url]
    
    render 'demo'
  end
  
  def demo
  end
  
  def status
    
  end
  
end
