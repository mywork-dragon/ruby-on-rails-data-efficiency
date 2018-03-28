class GooglePlayService
  include AppAttributeChecker

  class BadGoogleScrape < RuntimeError
    def initialize(app_identifier, attrs)
      msg = "#{app_identifier} invalid attributes: #{attrs}"
      super(msg)
    end
  end

  def is_compiled_css?
    return @compiled if @compiled.present?
    @compiled = !@html.at_css('div.details-section-contents')
  end

  # to reduce repeated doc queries
  def cached_attributes
    return @cached_attributes if @cached_attributes.present?
    res = {}
    m = /<div[^>]+class="([\w]+)">(\s*Offered By\s*)<\/div>/.match(@html.to_html)
    node = @html.css("div.#{m[1]}").select {|n| n.text == m[2]}.first
    meta_info = node.parent
    res[:details_section_node] = meta_info.parent
    res[:meta_info_nodes] = res[:details_section_node].css("div.#{meta_info.attributes['class'].value}")
    @cached_attributes = res
  end

  def initialize(page=nil)
    @page = page
  end

  def validate_attrs(res)
    failed_attributes = []
    failed_attributes << :name unless res[:name].present?
    failed_attributes << :released if res[:released].nil?
    failed_attributes << :category_id unless res[:category_id].present?
    failed_attributes << :developer_google_play_identifier unless res[:developer_google_play_identifier].present?
    failed_attributes << :description if res[:description].nil?
    failed_attributes << :seller unless res[:seller].present?
    if d = res[:downloads]
      failed_attributes << :downloads if d.min.nil? || d.max.nil?
    end
    if res[:similar_apps].present?
      failed_attributes << :similar_apps if res[:similar_apps].select { |x| /[^\w.]/.match(x) }.present?
    end
    failed_attributes
  end

  def attributes(app_identifier, proxy_type: :general)
    @proxy_type = proxy_type
    @html = google_play_html(app_identifier)

    ret = {}
    
    methods = %w(
      name
      description
      price
      seller
      seller_url
      category_name
      category_id
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
    # note: for speedup, in_app_purchases_range must come after in_app_purchases
    
    methods.each do |method|
      key = method.to_sym

      next if key == :in_app_purchases_range && !ret[:in_app_purchases]
    
      begin
        attribute = send(method.to_sym)
        ret[key] = attribute
      rescue
        ret[key] = nil
      end
    end

    # Added to prevent bad snaps from getting into DB.
    incorrect = validate_attrs(ret)
    if incorrect.present?
      raise BadGoogleScrape.new(app_identifier, incorrect)
    end

    ret
  end

  def google_play_html(app_identifier)
    page = @page || GooglePlayStore.lookup(app_identifier, proxy_type: @proxy_type).body
    Nokogiri::HTML(page)
  end

  def name
    n = unique_itemprop('h1', 'name') || unique_itemprop('div', 'name')
    n.text.strip
  end

  def description
    unique_itemprop('div', 'description').text.strip
  end

  # Returns price in dollars as float, 0.0 if product is free
  # NOTE: User must not be logged into Google Play account while using this - "Installed" app will register as free
  def price
    # Regular Expression strips string of all characters besides digits and decimal points
    price_dollars = unique_itemprop('meta', 'price')['content'].gsub(/[^0-9.]/, '').to_f
    (price_dollars*100.0).to_i
  end

  def seller
    meta_info_content_by_title('Offered By')
  end

  def seller_url
    node = meta_info_with_title('Developer')
    url = node.css('a').first['href']
    url = if /google\.com\/url/.match(url)
            UrlHelper.url_from_google_play(url)
          else
            url
          end
    UrlHelper.url_with_http_only(url)
  rescue
    nil
  end

  def category_name
    n = unique_itemprop('a', 'genre') || unique_itemprop('span', 'genre')
    n.text.strip
  end

  def category_id
    n = unique_itemprop('a', 'genre') || @html.at_css('.document-subtitle.category')
    n['href'].split('/')[-1]
  end

  def released
    date_text = meta_info_content_by_title('Updated') || meta_info_content_by_title('Released')
    date = Date.parse(date_text)
    raise 'Release date is in the future' if date.future?

    date
  end

  # Outputs file size as an integer in B, unless size stated as "Varies with device" in which nil is returned
  def size
    size_text = meta_info_content_by_title('Size')

    if size_text == "Varies with device"
      size = nil
    else
      size = Filesize.from(size_text + "iB").to_i # iB added to string to interface with filesize Gem convention
    end

    size
  end

  # Returns number GPlus "likes" as a integer, returns -1 if GPlus info span empty
  def google_plus_likes
    raise 'Not in use'

    # Finds link to Google Plus iframe on main Google Play Store page
    gplus_iframe_urls = @html.css("div.plusone-container > div > iframe")

    if gplus_iframe_urls.length < 1
      return -1
    end

    gplus_iframe = get(gplus_iframe_urls.first['src'])

    if gplus_iframe.css(".A8").text == ""
      return -1
    end

    # Splits string on spaces, grabs plus number & regular expression strips string of all characters besides digits
    gplus_iframe.css(".A8").text.split(" ")[0].gsub(/[^0-9]/,'').to_i

  end

  # Returns true if author is a "Top Developer", false if not
  def top_dev
    badge = unique_itemprop('meta', 'topDeveloperBadgeUrl')
    !!badge
  end

  # Returns true if app offers in-app purchases, false if not
  def in_app_purchases
    !!meta_info_with_title('In-app Products')
  end

  # Returns string of price range if in app purchases available, nil not (in cents)
  def in_app_purchases_range
    iap_s = meta_info_content_by_title('In-app Products')

    return unless iap_s.present?

    iap_a = iap_s.gsub('per item', '').split(' - ').map{ |x| (x.gsub('$', '').strip.to_f*100).to_i }

    return iap_a[0]..iap_a[1]
  end

  # Returns string of Android version required or "Varies with device"
  def required_android_version
    unique_itemprop('div', 'operatingSystems').try(:text).try(:strip) || meta_info_content_by_title('Requires Android')
  end

  # Returns string of current (app) version required or "Varies with device"
  def version
    meta_info_content_by_title('Current Version')
    # unique_itemprop('div', 'softwareVersion').text.strip
  end

  # Returns string of range detailing how many installs the app has, returns nil if data not available
  def downloads
    downloads_s = meta_info_content_by_title('Installs')
    downloads_a = downloads_s.split(' - ').map{ |x| x.strip.gsub(',', '').to_i }.sort

    # infer max for now. it's order of magnitude / 2
    # 100+ = 1000..5000
    # 5000+ = 5000..10000
    if downloads_a.count == 1
      min = downloads_a[0]
      max = 10**(Math.log10(min).floor + 1)
      max = max / 2 == min ? max : max / 2
      min..max
    else
      downloads_a[0]..downloads_a[1]
    end
  end

  # Returns a string containing the content rating, or nil if data not available
  def content_rating
    meta_info_content_by_title('Content Rating', child_index: 1).split("\n")[0].strip
  end

  # Returns float of app review rating (out of 5)
  def ratings_all_stars
    unique_itemprop('meta', 'ratingValue')['content'].to_f
  end
  
  # Returns integer of total number of app reviews
  def ratings_all_count
    unique_itemprop('meta', 'ratingCount')['content'].to_i
  end

  # Finds all listed "similar" apps on Play store
  def similar_apps
    @html.to_html.scan(/<a[^>]+href="\S*\/store\/apps\/details\?id=([\w.]+?)"/).flatten.uniq
  end

  def screenshot_urls
    urls = @html.css('img[itemprop="screenshot"]').map { |x| x['src'] }
    return urls if urls.present?
    @html.css('div[data-screenshot-item-index] img').map do |x|
      x['src'].gsub(/^https?:/, '')
    end
  end
  
  def icon_url_300x300
    unique_itemprop('img', 'image')['src']
  end

  # get a developer link on the page with contents that roughly match
  # the seller name
  def developer_google_play_identifier
    parts = seller.gsub(/\W/, ' ').split
    r = /<a[^>]*href="\S*\/store\/apps\/dev(?:eloper)?\?id=([^"]+?)"(.+?)<\/a>/
    match = @html.to_html.scan(r).find do |m|
      parts.reject { |p| m[1].include?(p) }.empty?
    end
    match[0]
  end

  def unique_itemprop(tag, itemprop, base: @html)
    base.at_css("#{tag}[itemprop=\"#{itemprop}\"]")
  end

  def meta_info_with_title(title)
    details = cached_attributes[:meta_info_nodes].find do |node|
      /#{title}/.match(node.text)
    end
  end

  def meta_info_content_by_title(title, child_index: -1)
    details = meta_info_with_title(title)
    details.children().reject {|x| x.class == Nokogiri::XML::Text}[child_index].text.strip if details
  end

  # Makes sure the scraping logic is still valid
  # (Checks to see if Google has changed their DOM)
  # @author Jason Lew
  def dom_valid?

    attributes = self.attributes('com.ubercab')

    attributes_expected = 
      {
        name: ->(x) { x == 'Uber' },
        description: ->(x) { x.class == String && x.include?('Uber') && x.length > 20 },
        price: ->(x) { x == 0 },
        seller: ->(x) { x == 'Uber Technologies, Inc.' },
        seller_url: ->(x) { x == 'http://uber.com' },
        category_name: ->(x) { x == 'Maps & Navigation' },
        category_id: ->(x) { x == 'MAPS_AND_NAVIGATION' },
        released: ->(x) { date_split = x.to_s.split('-'); date_split.count == 3 && date_split.first.to_i >= 2015 },
        # size: ->(x) { x.to_i > 1e7 },
        # top_dev: ->(x) { x == true },
        in_app_purchases: ->(x) { x == false },
        required_android_version: ->(x) { x == 'Varies with device' || x.to_i >= 4 },
        version: ->(x) { x == 'Varies with device' || x.to_i >= 3 },
        downloads: ->(x) { x.min >= 10e6},
        content_rating: ->(x) { x == 'Everyone'},
        ratings_all_stars: ->(x) { (1..5).include?(x) },
        ratings_all_count: ->(x) { x > 300000 },
        similar_apps: ->(x) { x.count > 0},
        screenshot_urls: ->(x) { x.count > 0},
        icon_url_300x300: ->(x) { x.present? },
        developer_google_play_identifier: ->(x) { x.present? },
      }

      all_attributes_pass?(attributes: attributes, attributes_expected: attributes_expected)
  end

  class << self

    def attributes(app_identifier, proxy_type: :general)
      self.new.attributes(app_identifier, proxy_type: proxy_type)
    end

    def dom_valid?
      self.new.dom_valid?
    end

  end
end
