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
    redirect_to :demo_you_are
    
    # @bizible_logo = view_context.image_path('bizible_logo.png')
    # @placements_io_logo = view_context.image_path('placements_io_logo.png')
    # @adroll_logo = view_context.image_path('adroll_logo.png')
  end
  
  def submit_demo
    puts "submit_demo params: #{params}"
    
    redirect_to action: :demo2
  end
  
  def demo_you_are
    
    # company_index = params['company_index'].to_i
    #
    # puts "params: #{params}"
    # puts "company_index: #{company_index}"
    
    company_index = 0
    
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
  
  def demo_companies
    service_names = [
                      "Marketo",
                      "Google AdWords Conversion",
                      "Optimizely",
                      "Google Analytics",
                      "KissMetrics",
                      "AdRoll",
                      "HubSpot",
                      "Criteo"
    ]
    
    @services = service_names.map{|service_name| Service.find_by_name(service_name)}
    
    puts "@services: #{@services}"
    
  end
  
  def demo_get_services
    url = params['url']
    
    services = ScrapeService.scrape_without_save(url)
    
    json = {services: services}
    
    render json: json
  end
  
  def demo_get_companies
    service_name = params['service_name']
    service_id = Service.find_by_name(service_name).id
    
    scrape_job_id = 33
    
    total_count = Installation.where(scrape_job_id: scrape_job_id, service_id: service_id).count
    
    limit = 100
    
    is = Installation.where(scrape_job_id: scrape_job_id, service_id: service_id).limit(limit)
    
    company_urls = []
    
    is.each do |i|
      company_urls << i.company.website
    end
    
    count = total_count - limit
    
    count = 0 if total_count < 0
    
    json = {company_urls: company_urls, count: count}
    
    #json = {company_urls: ["http://espn.com"]*50, count: 12345}
    
    puts "json: #{json}"
    
    render json: json
  end
  
  
end
