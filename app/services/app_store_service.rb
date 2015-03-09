class AppStoreService
  
  class << self
  
    def app_store_attributes(app_store_url)
      ret = {}
      
      html = app_store_html(app_store_url)
      
      ret[:title] = title(html)
      ret[:description] = description(html)
      ret[:whats_new] = whats_new(html)
      ret[:price] = price(html)
      ret[:seller_url] = seller_url(html)
      ret[:category] = category(html)
      ret[:updated] = updated(html)
      ret[:size] = size(html)
      ret[:languages] = languages(html)
      ret[:seller] = seller(html)
      ret[:developer_app_store_identifier] = developer_app_store_identifier(html)
      #ret[:ratings] = ratings(html)
      
      ret
      
      #ratings(html)
    end
    
    #private
    
    def app_store_html(app_store_url)
      url_cache = "http://webcache.googleusercontent.com/search?q=cache:#{app_store_url}"
      
      page = open(url_cache)
      Nokogiri::HTML(page)
    end 
    
    def title(html)
      html.css('#title.intro').css('.left').children[1].children.first.text
    end
    
    def description(html)
      html.css("div.center-stack > .product-review > p")[0].text
    end
    
    def whats_new(html)
      begin
        html.css("div.center-stack > .product-review > p")[1].text
      rescue
        nil
      end
    end
    
    # In cents
    # @author Jason Lew
    def price(html)
      price = 0.0
      price_text = html.css(".price").text.gsub("$", "")
      
      price = price_text.to_f unless price_text.strip == "Free"
      
      price*100.to_i
    end
    
    def seller_url(html)
      begin
        url = html.css(".app-links").children.first['href']
        UrlManipulator.url_with_http_only(url)
      rescue
        nil
      end
    end
    
    def category(html)
      html.css(".genre").children[1].text
    end
    
    def updated(html)
      Date.parse(html.css(".release-date").children[1].text)
    end
    
    # In B
    # @author Jason Lew
    def size(html)
      size_text = html.css('li').select{|li| li.text.match(/Size: /)}.first.children[1].text
      Filesize.from(size_text).to_i
    end
    
    def languages(html)
      begin
        languages_text = html.css('li').select{|li| li.text.match(/Languages*: /)}.first.children[1].text
        languages_text.split(', ')
      rescue 
        nil
      end
      
    end
    
    def seller(html)
      html.css('li').select{|li| li.text.match(/Seller: /)}.first.children[1].text
    end
    
    def developer_app_store_identifier(html)
      html.css("#title > div.right > a").first['href'].match(/\/id\d+/)[0].gsub("/id", "")
    end
    
    
    # def ratings(html)
    #   # html.css('.rating-star').count + 0.5*html.css('rating-star half').count
    #   customer_ratings = html.css('.customer-ratings')
    #   rating_count = customer_ratings.css
    #   rating
    # end
    
  end
end