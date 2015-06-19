# Manipulates URLs
# @author Jason Lew
class UrlHelper
  
  class << self
    
    def url_with_http_only(url)
      "http://" + url_with_base_only(url)
    end
    
    def url_with_base_only(url)
      regex = /^(http[s]*:\/\/)*(www.)*/
      url.match(regex) ? url.gsub(regex, "") : url
    end
    
    def url_with_domain_only(url)
      ret = url_with_base_only(url).gsub(/\/.*\z/, '')  #remove stuff after .com
      
      if match = ret.match(/\..*\..*/)
        ret = match[0].gsub(/\A./, '') 
      end
        
      ret
    end
    
    def url_with_http_and_domain(url)
      'http://' + url_with_domain_only(url)
    end
    
    def url_starts_with_http_or_https?(url)
      !url.match(/^(http[s]*:\/\/)*/)[0].blank?
    end
    
    def secondary_site?(url)
      app_page_regexes_strings = %w(
        facebook.com\/.+
        sites.google.com\/+.*
        plus.google.com\/+.*
        twitter.com\/.+
        pinterest.com\/.+
        facebook.com\/.+
        instagram.com\/.+
        apple.com\/.+
      )
    
      app_page_regexes = app_page_regexes_strings.map{|s| Regexp.new(s)}
    
      regex = Regexp.union(app_page_regexes)
    
      !url.match(regex).nil?
    end
    
    # Will get http://www.dropbox.com from:
    # https://www.google.com/url?q=http://www.dropbox.com&sa=D&usg=AFQjCNHkUkIvFbMV_t27v7cTn2Rd8cyuVw
    # @author Patrick Ellis
    def url_from_google_play(url)
      url.split('://')[2].split('&sa=D&usg=')[0]
    end
  
  end
  
end
