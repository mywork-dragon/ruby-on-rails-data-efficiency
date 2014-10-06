class SpidrService
  
  def run(url)
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
    
  end
  
end