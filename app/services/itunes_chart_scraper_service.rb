# Used in ItunesChartWorker

module ItunesChartScraperService

  class FreeApps

    def initialize
      @ranked_app_identifiers = nil
    end

    def ranked_app_identifiers
      return @ranked_app_identifiers if @ranked_app_identifiers
      store_html
      ranked_apps
    end

    private

    def store_html
      limit = 200
      url = "https://itunes.apple.com/us/rss/topfreeapplications/limit=#{limit}/xml"

      xml = nil
      open(url) do |f|
        xml = Nokogiri::XML(f.read())
      end
      @xml = xml
    end

    def ranked_apps
      ids = @xml.xpath('//xmlns:id')

      @ranked_app_identifiers = ids.map do |id|
       val = id['im:id']
       next nil if val.blank?
       val.to_i
      end.compact
    end

  end

end
