# Manipulates URLs
# @author Jason Lew
class UrlManipulator
  
  class << self
    
    def url_with_http_only(url)
      regex = /^http[s]*:\/\//

      if url.match(regex)
        url_with_http = url
      else
        url_with_http = "http://" + url
      end

      url_with_http
      
    end
    
    def url_with_base_only(url)
      regex = /^http[s]*:\/\//

      if url.match(regex)
        name = url.gsub(regex, "")
        url_with_http = url
      else
        name = url
      end

      name
      
    end
  
  end
  
end
