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
    @bizible_logo = view_context.image_path('bizible_logo.png')
    @placements_io_logo = view_context.image_path('placements_io_logo.png')
    @adroll_logo = view_context.image_path('adroll_logo.png')
  end
  
  def submit_demo
    puts "submit_demo params: #{params}"
    
    redirect_to action: :demo2
  end
  
  def demo2
    
    company_index = params['company_index'].to_i
    
    puts "params: #{params}"
    puts "company_index: #{company_index}"
    
    case company_index
    when 0
      @you_are = "Your name is Dave. You are the director of sales at Bizible."
      puts "ZERO"
      @pic_path = 'dave_bizible.jpg'
      @logo_path = 'bizible_logo.png'
    end
  end
  
  def demo3
    @currently = "You have literally thousands of leads, but you don't know which ones to pursue first. You know that companies that use Marketo and AdWords are prime targets for you to sell to, and you wish that there were some way to know which of your leads uses these services."
    @image_path = 'demo_csv_before.png'
  end
  
  def demo4
    @now = "Enter MightySignal. We figure out what services your leads are using. Now you know exactly whom you should be selling to."
    @image_path = 'demo_csv_after.png'
  end
  
  def demo5
    
  end
  
  def demo6
    @services = [
                  Service.find_by_name("Marketo"), 
                  Service.find_by_name("Google AdWords Conversion"),
                  Service.find_by_name("Optimizely"),
                  Service.find_by_name("Google Analytics"),
                  Service.find_by_name("KissMetrics"),
                  Service.find_by_name("AdRoll")
    ]
    
  end
  
  def services
    url = params['url']
    
    services = ScrapeService.scrape_test(url)
    
    json = {services: services}
    
    render json: json
  end
  
  def companies
    service_id = params['service_id']
    
    total_count = Installation.where(scrape_job_id: 15, service_id: service_id).count
    
    is = Installation.where(scrape_job_id: 15, service_id: service_id).limit(50)
    
    @company_urls = []
    
    is.each do |i|
      @company_urls << i.company.website
    end
    
    @count = total_count - 50
    
    @count = 0 if total_count < 0
    
    
  end
  
  
end
