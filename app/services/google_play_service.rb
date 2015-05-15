class GooglePlayService

  class << self

    def attributes(app_identifier)
      ret = {}

      @html = google_play_html(app_identifier)

      ret = {}

      # Checks if DOM is intact, exits method returning nil if not
      if @html.nil? || @html.at_css('.document-title').nil?
        return {}
      end
      
      methods = %w(
        name
        description
        price
        seller
        seller_url
        category
        released
        size
        top_dev
        in_app_purchases
        in_app_purchases_range
        required_android_version
        version
        downloads
        content_rating
        ratings_all_stars
        ratings_all_count
        similar_apps
        icon_url_300x300
        developer_google_play_identifier
      )
      
      methods.each do |method|
        key = method.to_sym
      
        begin
          attribute = send(method.to_sym)
        
          if attribute.class == String
            attribute = I18n.transliterate(attribute)
          end
        
          ret[key] = attribute
        rescue
          ret[key] = nil
        end
      
      end

      ret
    end


    #private

    def google_play_html(app_identifier)
      url = "https://play.google.com/store/apps/details?id=#{app_identifier}"
      
      page = Tor.get(url)

      Nokogiri::HTML(page)

      # Rescues error if issue opening URL
      rescue => e
        case e
          when OpenURI::HTTPError
            return nil
          when URI::InvalidURIError
            return nil
          else
            raise e
      end
    end

    # Returns string corresponding with supplied regex or nil if data not available
    def app_info_helper(regex)
      app_info_div = @html.css('div.details-section-contents > div.meta-info')
      in_app_cost_div = app_info_div.select{|div| div.children.children.text.match(regex)}
      if in_app_cost_div.length < 1
        return nil
      end
      in_app_cost_div.first.children.children[1].text.strip
    end


    def name
      @html.at_css('.document-title').text.strip
    end

    def description
      @html.at_css('div.id-app-orig-desc').text
    end

    # Returns price in dollars as float, 0.0 if product is free
    # NOTE: User must not be logged into Google Play account while using this - "Installed" app will register as free
    def price
      # Regular Expression strips string of all characters besides digits and decimal points
      price_dollars = @html.css("button.price > span:nth-child(3)").text.gsub(/[^0-9.]/,'').to_f
      (price_dollars*100.0).to_i
    end

    def seller
      @html.at_css('a.document-subtitle > span').text
    end

    def seller_url
      begin
        url = @html.css(".dev-link").first['href']
        url = UrlHelper.url_from_google_play(url)
        UrlHelper.url_with_http_only(url)
      rescue
        nil
      end
    end

    def category
      @html.at_css(".category").text.strip
    end

    def released
      date_text = @html.css('div.content').find{|c| c['itemprop'] == 'datePublished'}.text
      Date.parse(date_text)
    end

    # Outputs file size as an integer in B, unless size stated as "Varies with device" in which nil is returned
    def size
      size_text = @html.css("div.details-section-contents > div:nth-child(2) > div.content").text.strip

      if size_text == "Varies with device"
        size_text = nil
      else
        size_text = Filesize.from(size_text + "iB").to_i # iB added to string to interface with filesize Gem convention
      end

      size_text
    end

    # Returns number GPlus "likes" as a integer, returns -1 if GPlus info span empty
    def google_plus_likes

      # Finds link to Google Plus iframe on main Google Play Store page
      gplus_iframe_urls = @html.css("div.plusone-container > div > iframe")

      if gplus_iframe_urls.length < 1
        return -1
      end

      gplus_iframe = Tor.get(gplus_iframe_urls.first['src'])

      if gplus_iframe.css(".A8").text == ""
        return -1
      end

      # Splits string on spaces, grabs plus number & regular expression strips string of all characters besides digits
      gplus_iframe.css(".A8").text.split(" ")[0].gsub(/[^0-9]/,'').to_i

    end

    # Returns true if author is a "Top Developer", false if not
    def top_dev
      badge_title = @html.css('.badge-title')

      if badge_title.nil?
        return false
      end

      badge_title.text == "Top Developer"
    end

    # Returns true if app offers in-app purchases, false if not
    def in_app_purchases
      @html.css('.inapp-msg').text == "Offers in-app purchases"
    end

    # Returns string of price range if in app purchases available, nil not (in cents)
    def in_app_purchases_range
      cost_array = app_info_helper(/In-app Products/)
      if cost_array.nil?
        return nil
      end

      cost_array = cost_array.gsub('$','').split(" ")

      if cost_array.length > 3
        min = (cost_array[0].to_f*100.0).to_i
        max = (cost_array[2].to_f*100.0).to_i
        
        return min..max
      else
        min = (cost_array[0].to_f*100).to_i
        max = min
        
        return min..max
      end
    end

    # Returns string of Android version required or "Varies with device"
    def required_android_version
      result = app_info_helper(/Requires Android/).gsub(/[^0-9.]/,'')

      if result.length < 1
        return "Varies with device"
      end

      result
    end

    # Returns string of current (app) version required or "Varies with device"
    def version
      result = app_info_helper(/Current Version/).gsub(/[^0-9.]/,'')

      if result.length < 1
        return "Varies with device"
      end

      result
    end

    # Returns string of range detailing how many installs the app has, returns nil if data not available
    def downloads
      installs_array = app_info_helper(/Installs/)
      if installs_array.nil?
        return nil
      end

      installs_array_parsed = installs_array.gsub(',','').gsub(' -','').split(" ").map { |num| num.to_i }
      
      (installs_array_parsed.first..installs_array_parsed.last)
    end

    # Returns a string containing the content rating, or nil if data not available
    def content_rating
      app_info_helper(/Content Rating/)
    end

    # Returns float of app review rating (out of 5)
    def ratings_all_stars
      @html.css('div.rating-box > div.score-container > div.score').text.to_f
    end
    
    # Returns integer of total number of app reviews
    def ratings_all_count
      @html.css('.reviews-stats > .reviews-num').text.gsub(/[^0-9]/,'').to_i
    end

    # Finds all listed "similar" apps on Play store
    def similar_apps
      cards = Array.new

      @html.css('.card.no-rationale').each do |card|
        cards.push(card.css('a.card-click-target').first['href'].split('id=').last)
      end

      cards
    end
    
    def icon_url_300x300
      @html.css('div.details-info > div.cover-container > img').first['src']
    end
    
    def developer_google_play_identifier
      link = @html.css('div.more-from-developer').css('a.title-link.id-track-click').first['href']
      
      link.gsub('/store/apps/developer?id=', '').strip
    end
  end
end