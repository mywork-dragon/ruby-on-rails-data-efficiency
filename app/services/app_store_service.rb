class AppStoreService

  
  # Attributes hash
  # @author Jason Lew
  # @param id The App Store identifier
  def attributes(id, options={})
    @json = app_store_json(id)
    @html = app_store_html(id)
    
    #ld "@html: #{@html}"
    
    methods = []
    
    html_only = options[:html_only]
    
    if @json && !html_only
      methods += %w(
        title_json
        description_json
        release_notes_json
        price_json
        seller_url_json
        categories_json
        size_json
        seller_json
        developer_app_store_identifier_json
        ratings_json
        recommended_age_json
        required_ios_version_json
      )
    elsif @html || html_only
      methods += %w(
        title_html
        description_html
        release_notes_html
        price_html
        seller_url_html
        categories_html
        size_html
        seller_html
        developer_app_store_identifier_html
        ratings_html
        recommended_age_html
        required_ios_version_html
      )
    end
    
    # Must use HTML for these
    if @html
      methods += %w(
        support_url_html
        updated_html
        languages_html
        in_app_purchases_html
        editors_choice_html
      )
    end
    
    ret = {}
    
    # Go through the list of methods, call each one, and store it in ret
    # The key in ret is the method minus _json or _html at the end
    methods.each do |method|
      key = method.gsub(/_html\z/, '').gsub(/_json\z/, '').to_sym
      ret[key] = send(method.to_sym)
    end
    
    ret
  end
  
  # Gets the JSON through the iTunes Store API
  # Returns nil if cannot get JSON
  def app_store_json(id)
    begin
      page = open("https://itunes.apple.com/lookup?id=#{id}&limit=1")
      loaded_json = JSON.load(page)
      loaded_json['results'].first
    rescue
      le "Could not get JSON for app #{id}"
      nil
    end
  end

  def app_store_html(id)
    app_store_url = "https://itunes.apple.com/us/app/id#{id}"
    
    url_cache = "http://webcache.googleusercontent.com/search?q=cache:#{app_store_url}"
    
    url = app_store_url

    #li "url: #{url}"

    page = open(url, "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.122 Safari/537.36")
    html = Nokogiri::HTML(page)
    
    if html.css('#loadingbox-wrapper > div > p.title').text.match("Connecting to the iTunes Store")
      le "Taken to Connecting page"
      return nil
    end
    
    html
  end

  def title_json
    @json['trackName']
  end

  def title_html
    @html.css('#title > div.left > h1').text
  end

  def description_json
    @json['description']
  end
  
  def description_html
    @html.css("div.center-stack > .product-review > p")[0].text_replacing_brs
  end

  def release_notes_json
    @json['releaseNotes']
  end

  def release_notes_html
    begin
      @html.css("div.center-stack > .product-review > p")[1].text
    rescue
      nil
    end
  end

  # In cents
  # @author Jason Lew
  def price_json
    (@json['price'].to_f*100.0).to_i
  end

  # In cents
  # @author Jason Lew
  def price_html
    price = 0.0
    price_text = @html.css(".price").text.gsub("$", "")

    price = price_text.to_f unless price_text.strip == "Free"

    price*100.to_i
  end

  def seller_url_json
    @json['sellerUrl']
  end

  def seller_url_html
    begin
      children = @html.css(".app-links").children
      children.select{|c| c.text.match(/Site\z/)}.first['href']
    rescue
      nil
    end
  end

  # Only available in HTML 
  def support_url_html
    begin
      children = @html.css(".app-links").children
      children.select{|c| c.text.match(/Support\z/)}.first['href']
    rescue
      nil
    end
  end

  def categories_json
    primary = @json['primaryGenreName']
    all_cats = @json['genres']
    
    secondary = all_cats - [secondary]
    
    secondary = nil if secondary.blank?
    
    {primary: primary, secondary: secondary}
  end

  def categories_html
    primary = @html.css(".genre").children[1].text
    {primary: primary}
  end

  # Only available in HTML
  def updated_html
    date_text = @html.css(".release-date").children[1].text
    Date.parse(date_text)
  end

  #In B
  def size_json
    @json['fileSizeBytes']
  end

  # In B
  # @author Jason Lew
  def size_html
    size_text = @html.css('li').select{|li| li.text.match(/Size: /)}.first.children[1].text
    Filesize.from(size_text).to_i
  end

  # Only using HTML (abbreviations available in JSON)
  def languages_html
    begin
      languages_text = @html.css('li').select{|li| li.text.match(/Languages*: /)}.first.children[1].text
      languages_text.split(', ')
    rescue
      nil
    end

  end

  def seller_json
    @json['artistName']
  end
  
  def seller_html
    @html.css('li').select{|li| li.text.match(/Seller: /)}.first.children[1].text
  end

  def developer_app_store_identifier_json
    @json['artistId']
  end

  def developer_app_store_identifier_html
    @html.css("#title > div.right > a").first['href'].match(/\/id\d+/)[0].gsub("/id", "")
  end

  # HTML only
  def in_app_purchases_html
    lis = @html.css("#left-stack > div.extra-list.in-app-purchases > ol > li")
    lis.map{|li| {title: li.css("span.in-app-title").text, price: (li.css("span.in-app-price").text.gsub("$", "").to_f*100).to_i}}
  end

  def ratings_json
    current_version_hash = {}
    current_version_hash[:stars] = @json['averageUserRatingForCurrentVersion']
    current_version_hash[:ratings] = @json['userRatingCountForCurrentVersion']
    
    all_versions_hash = {}
    all_versions_hash[:stars] = @json['averageUserRating']
    all_versions_hash[:ratings] = @json['userRatingCount']
    
    
    {current: current_version_hash, all: all_versions_hash}
  end

  def ratings_html
    ratings = @html.css("#left-stack > div.extra-list.customer-ratings > div.rating")

    
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
  
  def recommended_age_json
    @json['trackContentRating']
  end
  
  def recommended_age_html
    @html.css("#left-stack > div.lockup.product.application > div.app-rating > a").text.gsub("Rated ", '')
  end
  
  def required_ios_version_json
    @json['minimumOsVersion']
  end
  
  def required_ios_version_html
    compatibility_text(@html).match(/Requires iOS (\d)+.(\d)/)[0].gsub('Requires iOS ', '').to_f
  end
  
  # HTML Only 
  def editors_choice_html
    @html.css(".editorial-badge").present?
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

  class << self
    
    # Attributes hash
    # @author Jason Lew
    # @param id The App Store identifier
    def attributes(id, options={})
      self.new.attributes(id, options)
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
    
      app_prefix = 'https://itunes.apple.com/us/app/'
      links = html.css("a").select{|a| a['href'].match(app_prefix) }.map{|a| a['href']}
      puts links
      
      ids = links.map{|link| link.match(/\/id\d*/)[0].gsub('/id', '')}
    
      limit = options[:limit]

      ids.each_with_index do |id, i|
        break if i == limit

        li "link: #{app_prefix}id#{id}"
        li attributes(id)
        #attributes(id)
        li ""
      end
    end

  end
end