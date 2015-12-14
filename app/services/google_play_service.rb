class GooglePlayService

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
      screenshot_urls
      icon_url_300x300
      developer_google_play_identifier
    )

    
    methods.each do |method|
      key = method.to_sym
    
      begin
        attribute = send(method.to_sym)
      
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

    #puts "url: #{url}"


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
  # Probably depricated 12/13/2015 -- jlew
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
    #@html.at_css('div.details-section-contents').css('div')
    @html.css('div').find{ |x| x['jsname'] == 'C4s9Ed'}.text
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
    date_text =  meta_infos_with_itemprop('datePublished')
    Date.parse(date_text)
  end

  # Outputs file size as an integer in B, unless size stated as "Varies with device" in which nil is returned
  def size
    size_text = meta_infos_with_itemprop('fileSize')

    if size_text == "Varies with device"
      size = nil
    else
      size = Filesize.from(size_text + "iB").to_i # iB added to string to interface with filesize Gem convention
    end

    size
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

    iap_s = meta_infos_with_title('In-app Products')

    iap_a = iap_s.gsub('per item', '').split(' - ').map{ |x| (x.gsub('$', '').strip.to_f*100).to_i }

    return iap_a[0]..iap_a[1]
  end

  # Returns string of Android version required or "Varies with device"
  def required_android_version
    meta_infos_with_itemprop('operatingSystems')
  end

  # Returns string of current (app) version required or "Varies with device"
  def version
    meta_infos_with_itemprop('softwareVersion')
  end

  # Returns string of range detailing how many installs the app has, returns nil if data not available
  def downloads
    downloads_s = meta_infos_with_itemprop('numDownloads')
    downloads_a = downloads_s.split(' - ').map{ |x| x.strip.gsub(',', '').to_i }
    
    (downloads_a[0]..downloads_a[1])
  end

  # Returns a string containing the content rating, or nil if data not available
  def content_rating
    meta_infos_with_itemprop('contentRating')
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

  def screenshot_urls
    begin
      @html.css(".screenshot").map{ |pic| pic['src'] }
    rescue => e
      nil
    end
  end
  
  def icon_url_300x300
    #@html.css('.cover-image').first['src']
    @html.css('div.details-info .cover-image').first['src']
  end
  
  def developer_google_play_identifier
    link = @html.css('a.document-subtitle.primary').first['href']
    
    ret = link.gsub('/store/apps/dev?id=', '').gsub('/store/apps/developer?id=', '').strip

    # workaround for developer identifier
    ret.length > 191 ? nil : ret
  end

  # gets all meta-info
  def meta_infos_with_itemprop(itemprop_value)
    @html.css('.meta-info').map(&:children).flatten.find{ |x| x['itemprop'] == itemprop_value}.text.strip
  end

  def meta_infos_with_title(title)
     @html.css('.meta-info').map(&:children).find{ |c| c.find{ |cc| cc['class'] == 'title' && cc.text.strip == title} }.find{ |c| c['class'] == 'content' }.text.strip
  end

  # Makes sure the scraping logic is still valid
  # (Checks to see if Google has changed their DOM)
  # @author Jason Lew
  def dom_valid?

    attributes = self.attributes('com.ubercab')

    ap attributes

    # ae: attributes expected 
    ae = 
      {
        name: ->(x) { x == 'Uber' },
        description: ->(x) { x.include? 'Get a reliable ride in minutes' },
        price: ->(x) { x == 0 },
        seller: ->(x) { x == 'Uber Technologies, Inc.' },
        seller_url: ->(x) { x == 'http://uber.com' },
        category: ->(x) { x == 'Transportation' },
        released: ->(x) { date_split = x.to_s.split('-'); date_split.count == 3 && date_split.first.to_i >= 2015},
        size: ->(x) { x.to_i > 1e7 },
        top_dev: ->(x) { x == true },
        in_app_purchases: ->(x) { x == false },
        required_android_version: ->(x) { x.to_i >= 4 },
        version: ->(x) { x.to_i >= 3 },
        downloads: ->(x) { x.min >= 10e6},
        content_rating: ->(x) { x == 'Everyone'},
        ratings_all_stars: ->(x) { (1..5).include?(x) },
        ratings_all_count: ->(x) { x > 300000 },
        similar_apps: ->(x) { x.count > 0},
        screenshot_urls: ->(x) { x.count > 0},
        icon_url_300x300: ->(x) { x.present? },
        developer_google_play_identifier: ->(x) { x.present? },
      }

      ret = true

      ae.each do |expected_attribute_key, expected_attribute_value|
        attribute_value = attributes[expected_attribute_key]

        pass = ae[expected_attribute_key].call(attribute_value)

        if pass
          puts "#{expected_attribute_key}: PASS".green
        else
          ret = false
          puts "#{expected_attribute_key}: FAIL".red
          puts "#{attribute_value}".purple
        end

        puts ""

      end

    ret
  end

  class << self

    def attributes(app_identifier)
      self.new.attributes(app_identifier)
    end

    def dom_valid?
      self.new.dom_valid?
    end

  end
end