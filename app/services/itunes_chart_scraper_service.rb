module ItunesChartScraperService

  class FreeApps

    def scrape_apps(proxy_type: nil)
      get_html(proxy_type: proxy_type)
      get_apps
    end

    def get_html(proxy_type: nil)
      limit = 200
      url = l

      if proxy_type == :tor
        page = Tor.get(url)
      elsif proxy_type == nil
        page = Proxy.get_body_from_url(url)
      end

      @xml = Nokogiri::XML(page)
    end

    def get_apps
      ids = @xml.xpath('//xmlns:id')

      ids.map do |id|
       val = id['im:id']
       next nil if val.blank?
       val.to_i
      end.compact
    end

    class << self

      # proxy_type can be :tor or nil for no proxy
      def scrape_apps(proxy_type: nil)
        self.new.scrape_apps(proxy_type: proxy_type)
      end

    end

  end

end