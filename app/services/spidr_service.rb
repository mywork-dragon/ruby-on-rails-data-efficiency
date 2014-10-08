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
    Spidr.site(url) do |spider|
      spider.every_url do |url|
        puts "url visited: #{url}"
      end
    end
  end
  
  class << self
  
    def run(url)
      SpidrService.new.run(url)
    end
    
    def run_angellist
      SpidrService.new.run("http://angel.co")
    end
    
    def test
      url = "https://angel.co/airbnb/"
      
      data = Nokogiri::HTML(open(url))
      
      company_url_classes = data.css(".company_url")
      
      puts "company_url_classes: #{company_url_classes}"
      
      company_url_class = company_url_classes.first
      
      company_url = company_url_class.child
      
      puts "url: #{company_url}"
    end
    
  end
  
end