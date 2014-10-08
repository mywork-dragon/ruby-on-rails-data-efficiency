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
      
      tr_techs = data.css(".company_url")
      
      puts "tr_techs: #{tr_techs}"

      # tr_techs.each do |tr_tech|
      #   puts "tr_tech: #{tr_tech}"
      #   # company_name = tr_tech.css('td')[1].child.child
      #   #
      #   # company_names << company_name
      # end
      
      tr_tech = tr_techs.first
      
      puts tr_tech.child
    end
    
  end
  
end