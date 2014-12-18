# Manipulates URLs
# @author Jason Lew
class UrlManipulator
  
  class << self
    
    def url_with_http_only(url)
      "http://" + self.url_with_base_only(url)
    end
    
    def url_with_base_only(url)
      regex = /^(http[s]*:\/\/)*(www.)*/

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
