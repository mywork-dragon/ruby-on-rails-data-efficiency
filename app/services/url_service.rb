# Manipulates URLs
# @author Jason Lew
class UrlService
  
  class << self
    
    def url_with_http_only(url)
      regex = /^http[s]*:\/\//

      if url.match(regex)
        name = url.gsub(regex, "")
        url_with_http = url
      else
        name = url
        url_with_http = "http://" + url
      end

      url_with_http
      
    end
  
  end
  
end
