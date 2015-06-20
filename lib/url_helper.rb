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
      Domainator.parse(url)
      
      # ret = url_with_base_only(url).gsub(/\/.*\z/, '')  #remove stuff after .com
      #
      # if match = ret.match(/\..*\..*/)
      #   ret = match[0].gsub(/\A./, '')
      # end
      #
      # ret
    end
    
    def url_with_http_and_domain(url)
      'http://' + url_with_domain_only(url)
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

    def known_website(url)
      sites = 
      {
        "sites.google.com" => 281956209,
        "plus.google.com" => 281956209,
        "pinterest.com" => 429047995,
        "apple.com" => 284417353,
        "youtube.com" => 281956209,
        "zendesk.com" => 368796010,
        "sina.com.cn" => 291478092,
        "sina.com" => 291478092,
        "wix.com" => 407141669,
        "tumblr.com" => 305343407,
        "webs.com" => 0,
        "weibo.com" => 291478092,
        "uservoice.com" => 370742542,
        "helpshift.com" => 0,
        "blog.com" => 0,
        "appspot.com" => 0,
        "naver.com" => 311867731,
        "github.com" => 0,
        "yelp.com" => 284910353,
        "weebly.com" => 511158312,
        "wordpress.com" => 335703883,
        "subway.com" => 860751246,
        "blogspot.com" => 0,
        "evernote.com" => 281796111,
        "imdb.com" => 342792528,
        "facebook.com" => 284882218,
        "twitter.com" => 296415947,
        "instagram.com" => 389801255,
        "foursquare.com" => 306934924,
        "ask.fm" => 635896476
      }
      sites.each{ |site, dev_id| return dev_id if url.include?(site) }
      nil
    end

    
    # Will get http://www.dropbox.com from:
    # https://www.google.com/url?q=http://www.dropbox.com&sa=D&usg=AFQjCNHkUkIvFbMV_t27v7cTn2Rd8cyuVw
    # @author Patrick Ellis
    def url_from_google_play(url)
      url.split('://')[2].split('&sa=D&usg=')[0]
    end
  
  end
  
end
