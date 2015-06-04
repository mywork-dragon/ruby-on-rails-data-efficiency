class GoogleResults

  class << self

    def search query
      googleUrl = "http://www.google.com/search?q=" + query
      googleResults = Nokogiri::HTML(open(googleUrl))
      # links = googleResults.xpath("//h3[@class=\"r\"]/a/@href").to_json
      links = googleResults.xpath("//h3[@class=\"r\"]/a")

    end

  end

end
