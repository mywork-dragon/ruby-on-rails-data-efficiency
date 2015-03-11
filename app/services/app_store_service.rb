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
      ret[:in_app_purchases] = in_app_purchases(html)
      ret[:ratings] = ratings(html)
      ret[:recommended_age] = recommended_age(html)

      ret

      #ratings(html)
    end

    def app_store_html(app_store_url)
      url_cache = "http://webcache.googleusercontent.com/search?q=cache:#{app_store_url}"

      #page = open(url_cache)
      page = open(app_store_url)
      Nokogiri::HTML(page)
    end

    def title(html)
      html.css('#title.intro').css('.left').children[1].children.first.text
    end

    def description(html)
      desc_element = html.css("div.center-stack > .product-review > p")[0]
      ScrapeHelper.node_to_text_replacing_brs(desc_element)
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

    def in_app_purchases(html)
      lis = html.css("#left-stack > div.extra-list.in-app-purchases > ol > li")
      lis.map{|li| {title: li.css("span.in-app-title").text, price: (li.css("span.in-app-price").text.gsub("$", "").to_f*100).to_i}}
    end

    def ratings(html)
      ratings = html.css("#left-stack > div.extra-list.customer-ratings > div.rating")

      if ratings.count == 1
        all_versions_s = ratings.first["aria-label"]
      else
        current_version_s = ratings.first["aria-label"]
        all_versions_s = ratings[1]["aria-label"]
      end


      if current_version_s
        current_version_split = current_version_s.split(", ")
        current_version_hash = {}
        current_version_hash[:stars] = count_stars(current_version_split[0])
        current_version_hash[:ratings] = count_ratings(current_version_split[1])
      end

      all_versions_split = all_versions_s.split(", ")
      all_versions_hash = {}
      all_versions_hash[:stars] = count_stars(all_versions_split[0])
      all_versions_hash[:ratings] = count_ratings(all_versions_split[1])

      {current: current_version_hash, all: all_versions_hash}
    end
    
    def recommended_age(html)
      html.css("#left-stack > div.lockup.product.application > div.app-rating > a").text.gsub("Rated ", '')
    end
    
    private
    
      # 3 and a half stars --> 3.5
      # @author Jason Lew
      def count_stars(s)
        s.gsub("stars", "").strip.gsub(" and a half", ".5").to_f
      end

      def count_ratings(s)
        s.gsub("Ratings", "").strip.to_i
      end

  end
end