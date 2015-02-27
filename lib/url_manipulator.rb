# Manipulates URLs
# @author Jason Lew
class UrlManipulator
  
  class << self
    
    def url_with_http_only(url)
      "http://" + url_with_base_only(url)
    end
    
    def url_with_base_only(url)
      regex = /^(http[s]*:\/\/)*(www.)*/
      url.match(regex) ? url.gsub(regex, "") : url
    end
  
  end
  
end
