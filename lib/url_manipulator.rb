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
    
    def url_with_domain_only(url)
      url_with_base_only(url).gsub(/\/.*\z/, '')
    end
    
    # Will get http://www.dropbox.com from:
    # https://www.google.com/url?q=http://www.dropbox.com&sa=D&usg=AFQjCNHkUkIvFbMV_t27v7cTn2Rd8cyuVw
    # @author Patrick Ellis
    def url_from_google_play(url)
      url.split('://')[2].split('&sa=D&usg=')[0]
    end
  
  end
  
end
