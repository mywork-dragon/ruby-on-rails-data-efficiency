require 'nokogiri'
require 'open-uri'

class SpidrService
  
  def run(url)
    Spidr.site(url) do |spider|
      spider.every_url do |url|
        puts "url visited: #{url}"
      end
    end
  end
  
  def run_angellist(url)
    
    i = 0
    cutoff = 50
    
    #urls = []
    
    Spidr.site(url) do |spider|
      spider.every_url do |url|
        puts "url visited: #{url}"
        
        company_url = company_url_from_angellist_url(url)
        
        if company_url.nil?
          puts "could not find company URL"
        else
          # urls << company_url
          puts "FOUND! URL: #{company_url}"

          name = ""

          regex = /^http[s]*:\/\//

          if company_url.match(regex)
            name = company_url.gsub(regex, "")
            company_url_with_http = company_url
          else
            name = company_url
            company_url_with_http = "http://" + company_url
          end

          puts "company_url_with_http: #{company_url_with_http}"

          company = Company.find_by_website(company_url_with_http)

          if company.nil?
            created = Company.create(name: name, website: company_url_with_http, status: :active)
            
            if created
              puts "Added #{name} (#{company_url_with_http} to DB)"
            else
              puts "Error adding #{name} (#{company_url_with_http}) to DB"
            end
            
          else
            puts "company already in DB"
          end
        end
        
        puts ""
        
        i += 1
        
        if i == cutoff
          #return urls
          return
        end
      end
    end
    
    #urls
  end
  
  def company_url_from_angellist_url(url)
    data = Nokogiri::HTML(open(url))
  
    company_url_classes = data.css(".company_url")
  
    if company_url_classes.blank?
      return nil
    end
  
    #puts "company_url_classes: #{company_url_classes}"
  
    company_url_class = company_url_classes.first
  
    company_url = company_url_class.child.to_s
  end
  
  class << self
  
    def run(url)
      SpidrService.new.run(url)
    end
    
    def run_angellist
      SpidrService.new.run_angellist("https://angel.co")
    end
    
    def test
      url = "https://angel.co/airbnb/"
      
      data = Nokogiri::HTML(open(url))
      
      company_url_classes = data.css(".company_url")
      
      if company_url_class.nil?
        puts "couldn't find"
        return
      end
      
      puts "company_url_classes: #{company_url_classes}"
      
      company_url_class = company_url_classes.first
      
      company_url = company_url_class.child
      
      puts "url: #{company_url}"
    end
    
  end
  
end