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
    cutoff = 20
    
    Spidr.site(url) do |spider|
      spider.every_url do |url|
        puts "url visited: #{url}"
        
        company_url = company_url_from_angellist_url(url)
        
        if company_url.nil?
          puts "could not find company URL"
        else
          puts "FOUND! URL#{company_url}"
        end
        
        puts ""
        
        i += 1
        
        break if i == cutoff
      end
    end
  end
  
  def company_url_from_angellist_url(url)
    data = Nokogiri::HTML(open(url))
  
    company_url_classes = data.css(".company_url")
  
    if company_url_classes.blank?
      puts "couldn't find"
      return nil
    end
  
    puts "company_url_classes: #{company_url_classes}"
  
    company_url_class = company_url_classes.first
  
    company_url = company_url_class.child
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