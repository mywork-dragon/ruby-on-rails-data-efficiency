class AppStoreService

  class << self

    # Attributes hash
    # @author Jason Lew
    # @param id The App Store identifier
    def app_store_attributes(id)
      ret = {}
      
      json = app_store_json(id)

      html = app_store_html(id)

      ret[:title] = title(html)
      ret[:description] = description(html)
      ret[:whats_new] = whats_new(html)
      ret[:price] = price(html)
      ret[:seller_url] = seller_url(html) 
      ret[:contact_url] = contact_url(html)
      ret[:category] = category(html)
      ret[:updated] = updated(html)
      ret[:size] = size(html)
      ret[:languages] = languages(html)
      ret[:seller] = seller(html)
      ret[:developer_app_store_identifier] = developer_app_store_identifier(html)
      ret[:in_app_purchases] = in_app_purchases(html)
      ret[:ratings] = ratings(html)
      ret[:recommended_age] = recommended_age(html)
      ret[:required_ios_version] = required_ios_version(html)
      ret[:editors_choice] = editors_choice(html)

      ret
    end
    
    def app_store_json(id)
      page = open("https://itunes.apple.com/lookup?id=#{id}")
      JSON.load(page)['results'].first
    end

    def app_store_html(id)
      app_store_url = "https://itunes.apple.com/us/app/melt-voice-your-important/id#{id}"
      
      url_cache = "http://webcache.googleusercontent.com/search?q=cache:#{app_store_url}"

      #page = open(url_cache)
      page = open(app_store_url)
      Nokogiri::HTML(page)
    end

    def title(html)
      html.css('#title > div.left > h1').text
    end

    def description(html)
      # html.css("div.center-stack > .product-review > p")[0].text_replacing_brs
      html.css("div.center-stack > .product-review > p")
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

    def contact_url(html)
      begin
        html.css(".app-links").children[1]['href']
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
      elsif ratings.count >= 2
        current_version_s = ratings.first["aria-label"]
        all_versions_s = ratings[1]["aria-label"]
      end


      if current_version_s
        current_version_split = current_version_s.split(", ")
        current_version_hash = {}
        current_version_hash[:stars] = count_stars(current_version_split[0])
        current_version_hash[:ratings] = count_ratings(current_version_split[1])
      end

      if all_versions_s
        all_versions_split = all_versions_s.split(", ")
        all_versions_hash = {}
        all_versions_hash[:stars] = count_stars(all_versions_split[0])
        all_versions_hash[:ratings] = count_ratings(all_versions_split[1])
      end
      
      {current: current_version_hash, all: all_versions_hash}
    end
    
    def recommended_age(html)
      html.css("#left-stack > div.lockup.product.application > div.app-rating > a").text.gsub("Rated ", '')
    end
    
    def required_ios_version(html)
      compatibility_text(html).match(/Requires iOS (\d)+.(\d)/)[0].gsub('Requires iOS ', '').to_f
    end
    
    def editors_choice(html)
      html.css(".editorial-badge").present?
    end
    
    def test(options={})
      # links = %w(
      #   https://itunes.apple.com/us/app/a$$hole-by-martin-kihn/id389377362?mt=8
      #   https://itunes.apple.com/us/app/adan-zye/id576204516?mt=8
      #   https://itunes.apple.com/us/app/kindle-read-books-ebooks-magazines/id302584613?mt=8
      #   https://itunes.apple.com/us/app/audiobooks-from-audible/id379693831?mt=8
      #   https://itunes.apple.com/us/app/nook/id373582546?mt=8
      #   https://itunes.apple.com/us/app/wattpad-free-books-ebook-reader/id306310789?mt=8
      #   https://itunes.apple.com/us/app/overdrive-library-ebooks-audiobooks/id366869252?mt=8
      #   https://itunes.apple.com/us/app/goodreads-book-recommendations/id355833469?mt=8
      # )
      
      page = open('https://itunes.apple.com/us/genre/ios-games/id6014')
      html = Nokogiri::HTML(page)
      
      links = html.css("a").select{|a| a['href'].match('https://itunes.apple.com/us/app') }.map{|a| a['href']}
      
      limit = options[:limit]
      
      links.each_with_index do |link, i|
        break if i == limit
        
        li "link: #{link}"
        li app_store_attributes(link)
        li ""
      end
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

      def compatibility_text(html)
        html.css('#left-stack > div.lockup.product.application > p > span.app-requirements').first.parent.children[1].text
      end

  end
end