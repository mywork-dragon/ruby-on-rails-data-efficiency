class FaviconService
  class << self

    # returns a favicon url
    def get_favicon_from_url(url:)
      url = "http://#{url}" if URI.parse(url).scheme.nil? # put http on the front
      host = URI.parse(url).host || ""
      host = host.gsub(/^www\./, '')
      "https://www.google.com/s2/favicons?domain=#{host}"
    end

    # use google default by giving a non-existing domain
    def get_default_favicon
      get_favicon_from_url(url: "http://hellostephenisneat.edu")
    end

  end
end
