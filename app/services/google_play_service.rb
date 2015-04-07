class GooglePlayService

  class << self

    def attributes(app_identifier)
      ret = {}

      html = google_play_html(app_identifier)

      # Checks if DOM is intact, exits method returning nil if not
      if html.nil? || html.at_css('.document-title').nil?
        return nil
      end

      ret[:title] = title(html)
      ret[:price] = price(html)
      ret[:seller] = seller(html)
      ret[:seller_url] = seller_url(html)
      ret[:category] = category(html)
      ret[:updated] = updated(html)
      ret[:size] = size(html)
      ret[:google_plus_likes] = google_plus_likes(html)
      ret[:top_dev] = top_dev(html)
      ret[:in_app] = in_app(html)
      ret[:in_app_cost] = in_app_cost(html)
      ret[:required_android_version] = required_android_version(html)
      ret[:current_version] = current_version(html)
      ret[:installs] = installs(html)
      ret[:content_rating] = content_rating(html)
      ret[:user_rating_avg] = user_rating_avg(html)
      ret[:num_user_reviews] = num_user_reviews(html)
      ret[:similar_apps] = similar_apps(html)

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
    def app_info_helper(html, regex)
      app_info_div = html.css('div.details-section-contents > div.meta-info')
      in_app_cost_div = app_info_div.select{|div| div.children.children.text.match(regex)}
      if in_app_cost_div.length < 1
        return nil
      end
      in_app_cost_div.first.children.children[1].text.strip
    end


    def title(html)
      html.at_css('.document-title').text.strip
    end

    # Returns price in dollars as float, 0.0 if product is free
    # NOTE: User must not be logged into Google Play account while using this - "Installed" app will register as free
    def price(html)
      # Regular Expression strips string of all characters besides digits and decimal points
      html.css("button.price > span:nth-child(3)").text.gsub(/[^0-9.]/,'').to_f
    end

    def seller(html)
      html.at_css('a.document-subtitle > span').text
    end

    def seller_url(html)
      begin
        url = html.css(".dev-link").first['href']
        url = UrlManipulator.url_from_google_play(url)
        UrlManipulator.url_with_http_only(url)
      rescue
        nil
      end
    end

    def category(html)
      html.at_css(".category").text.strip
    end

    def updated(html)
      Date.parse(html.css("div.details-section-contents > div.meta-info > div.content").text)
    end

    # Outputs file size as an integer in B, unless size stated as "Varies with device" in which -1 is returned
    def size(html)
      size_text = html.css("div.details-section-contents > div:nth-child(2) > div.content").text.strip

      if size_text == "Varies with device"
        size_text = -1
      else
        size_text = Filesize.from(size_text + "iB").to_i # iB added to string to interface with filesize Gem convention
      end

      size_text
    end

    # Returns number GPlus "likes" as a integer, returns -1 if GPlus info span empty
    def google_plus_likes(html)

      # Finds link to Google Plus iframe on main Google Play Store page
      gplus_iframe_urls = html.css("div.plusone-container > div > iframe")

      if gplus_iframe_urls.length < 1
        return -1
      end

      gplus_iframe = Nokogiri::HTML(open(gplus_iframe_urls.first['src']))

      if gplus_iframe.css(".A8").text == ""
        return -1
      end

      # Splits string on spaces, grabs plus number & regular expression strips string of all characters besides digits
      gplus_iframe.css(".A8").text.split(" ")[0].gsub(/[^0-9]/,'').to_i

    end

    # Returns true if author is a "Top Developer", false if not
    def top_dev(html)
      badge_title = html.css('.badge-title')

      if badge_title.nil?
        return false
      end

      badge_title.text == "Top Developer"
    end

    # Returns true if app offers in-app purchases, false if not
    def in_app(html)
      html.css('.inapp-msg').text == "Offers in-app purchases"
    end

    # Returns string of price range if in app purchases available, nil not (in cents)
    def in_app_cost(html)
      cost_array = app_info_helper(html, /In-app Products/)
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
    def required_android_version(html)
      result = app_info_helper(html, /Requires Android/).gsub(/[^0-9.]/,'')

      if result.length < 1
        return "Varies with device"
      end

      result
    end

    # Returns string of current (app) version required or "Varies with device"
    def current_version(html)
      result = app_info_helper(html, /Current Version/).gsub(/[^0-9.]/,'')

      if result.length < 1
        return "Varies with device"
      end

      result
    end

    # Returns string of range detailing how many installs the app has, returns nil if data not available
    def installs(html)
      installs_array = app_info_helper(html, /Installs/)
      if installs_array.nil?
        return nil
      end

      installs_array_parsed = installs_array.gsub(',','').gsub(' -','').split(" ").map { |num| num.to_i }
      
      (installs_array_parsed.first..installs_array_parsed.last)
    end

    # Returns a string containing the content rating, or nil if data not available
    def content_rating(html)
      app_info_helper(html, /Content Rating/)
    end

    # Returns float of app review rating (out of 5)
    def user_rating_avg(html)
      html.css('div.rating-box > div.score-container > div.score').text.to_f
    end

    # Returns integer of total number of app reviews
    def num_user_reviews(html)
      html.css('.reviews-stats > .reviews-num').text.gsub(/[^0-9]/,'').to_i
    end

    # Finds all listed "similar" apps on Play store
    def similar_apps(html)
      cards = Array.new

      html.css('.card.no-rationale').each do |card|
        cards.push(card.css('a.card-click-target').first['href'].split('id=').last)
      end

      cards
    end
  end
end