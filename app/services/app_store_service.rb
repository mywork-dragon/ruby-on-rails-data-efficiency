class AppStoreService

  include AppAttributeChecker

  attr_accessor :json

  # Attributes hash
  # @author Jason Lew
  # @param id The App Store identifier
  def attributes(id, country_code: 'us', lookup: true, scrape: true)
    @country_code = country_code
    
    @json = app_store_json(id) if lookup
    @html = app_store_html(id) if scrape
    
    #ld "@html: #{@html}"
    
    methods = []
    
    if @json
      check_ios # check to make sure it's an iOS app

      methods += json_methods
    end
    
    if @html
      if !@json # if could not get JSON, need to get these from scrape
        methods += %w(
          name_html
          description_html
          release_notes_html
          version_html
          price_html
          seller_url_html
          categories_html
          size_html
          seller_html
          by_html
          developer_app_store_identifier_html
          ratings_html
          recommended_age_html
          required_ios_version_html
          screenshot_urls_html
          released_html
        )
      end
      
      methods += %w(
        support_url_html
        languages_html
        in_app_purchases_html
        editors_choice_html
        copywright_html
        seller_url_text_html
        support_url_text_html
        icon_urls_html
      )

    end
    
    ret = {}
    
    # Go through the list of methods, call each one, and store it in ret
    # The key in ret is the method minus _json or _html at the end
    methods.each do |method|
      key = method.gsub(/_html\z/, '').gsub(/_json\z/, '').to_sym
      
      begin
        attribute = send(method.to_sym)
        
        ret[key] = attribute
      rescue
        ret[key] = nil
      end
      
    end
    
    ret
  end

  def json_methods
    # new ones start at released -- jason

    %w(
      app_identifier_json
      name_json
      description_json
      release_notes_json
      version_json
      price_json
      seller_url_json
      categories_json
      size_json
      seller_json
      by_json
      developer_app_store_identifier_json
      ratings_json
      recommended_age_json
      required_ios_version_json
      first_released_json
      screenshot_urls_json
      released_json
      ratings_current_stars_json
      ratings_current_count_json
      ratings_all_stars_json
      ratings_all_count_json
      icon_url_512x512_json
      icon_url_100x100_json
      icon_url_60x60_json
      game_center_enabled_json
      bundle_identifier_json
      currency_json
      category_ids_json
      )
  end
  
  # Gets the JSON through the iTunes Store API
  # Returns nil if cannot get JSON
  def app_store_json(id)
    loaded_json = ItunesApi.lookup_app_info(id)
    raise AppDoesNotExist if loaded_json['resultCount'] == 0
    loaded_json['results'].first
  end

  def app_store_html(id)
    app_store_url = "https://itunes.apple.com/#{@country_code}/app/id#{id}"

    html = nil
    open(app_store_url) do |f|
      html = Nokogiri::HTML(f.read())
    end

    if html.css('#loadingbox-wrapper > div > p.title').text.match("Connecting to the iTunes Store")
      le "Taken to Connecting page"
      return nil
    end
    
    html
  end

  # Make sure it's an iOS app.
  # Will throw an exception if not
  def check_ios
    raise NotIosApp if @json['wrapperType'] != 'software' || @json['kind'] != 'software'
    true
  end

  def app_identifier_json
    @json['trackId']
  end

  def name_json
    @json['trackName']
  end

  def name_html
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
    @html.css("div.center-stack > .product-review > p")[1].text
  end

  def version_json
    @json['version']
  end
  
  def version_html
    size_text = @html.css('li').select{ |li| li.text.match(/Version: /) }.first.children[1].text
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
    ret = @json['sellerUrl']
    return nil if UrlHelper.url_with_base_only(ret).blank?
    ret
  end

  def seller_url_html
    children = @html.css(".app-links").children
    children.select{ |c| c.text.match(/Site\z/) }.first['href']
  end

  # Only available in HTML 
  def support_url_html
    children = @html.css(".app-links").children
    children.select{ |c| c.text.match(/Support\z/) }.first['href']
  end

  def categories_json
    all_cats = @json['genres']
    primary = all_cats.first

    secondary = all_cats - [primary]
    
    {primary: primary, secondary: secondary}
  end

  def categories_html
    primary = @html.css(".genre").children[1].text
    {primary: primary, secondary: []}
  end

  def released_html
    date_text = @html.css(".release-date").children[1].text
    Date.parse(date_text)
  end

  # In B
  def size_json
    @json['fileSizeBytes']
  end

  # In B
  # @author Jason Lew
  def size_html
    size_text = @html.css('li').select{ |li| li.text.match(/Size: /) }.first.children[1].text
    Filesize.from(size_text).to_i
  end

  # Only using HTML (abbreviations available in JSON)
  def languages_html
    languages_text = @html.css('li').select{ |li| li.text.match(/Languages*: /) }.first.children[1].text
    languages_text.split(', ')
  end

  def seller_json
    @json['sellerName']
  end
  
  def seller_html
    @html.css('li').select{ |li| li.text.match(/Seller: /) }.first.children[1].text
  end

  def by_json
    @json['artistName']
  end

  def by_html
    @html.css('#title > div.left').children.find{ |c| c.name == 'h2' }.text.gsub(/\ABy /, '')
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
    lis.map{ |li| {name: li.css("span.in-app-title").text, price: (li.css("span.in-app-price").text.gsub("$", "").to_f*100).to_i} }
  end

  def ratings_json
    current_version_hash = {}
    current_version_hash[:stars] = ratings_current_stars_json
    current_version_hash[:count] = ratings_current_count_json
    
    all_versions_hash = {}
    all_versions_hash[:stars] = ratings_all_stars_json
    all_versions_hash[:count] = ratings_all_count_json
    
    
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

  def screenshot_urls_json
    @json['screenshotUrls']
  end

  def screenshot_urls_html
    begin
      @html.css(".iphone-screen-shots > div > div > img").map{ |pic| pic['src'] }
    rescue => e
      nil
    end
  end
  
  def required_ios_version_json
    @json['minimumOsVersion']
  end
  
  def first_released_json
    @json['releaseDate'].to_date
  end

  def released_json
    @json['currentVersionReleaseDate'].to_date
  end

  def ratings_current_stars_json
    @json['averageUserRatingForCurrentVersion'].to_f
  end
  
  def ratings_current_count_json
    @json['userRatingCountForCurrentVersion'].to_i
  end

  def ratings_all_stars_json
    @json['averageUserRating'].to_f
  end

  def ratings_all_count_json
    @json['userRatingCount'].to_i
  end
    
  def icon_url_512x512_json
    @json['artworkUrl512']
  end
  
  def icon_url_100x100_json
    @json['artworkUrl100']
  end

  def icon_url_60x60_json
    @json['artworkUrl60']
  end

  def game_center_enabled_json
    @json['isGameCenterEnabled']
  end
  
  def bundle_identifier_json
    @json['bundleId']
  end
  
  def currency_json
    @json['currency']
  end

  def category_ids_json
    primary = @json['primaryGenreId']
    all_cats = @json['genreIds'].map(&:to_i)
    
    secondary = all_cats - [primary]
    
    {primary: primary, secondary: secondary}
  end
  
  def required_ios_version_html
    compatibility_text(@html).match(/Requires iOS (\d)+.(\d)/)[0].gsub('Requires iOS ', '').to_f
  end
  
  # HTML Only 
  def editors_choice_html
    @html.css(".editorial-badge").present?
  end
  
  def icon_urls_html
    node = @html.css('#left-stack').css('.artwork').css('div > img').first
    
    ret = {size_350x350: nil, size_175x175: nil}
    
    ret = {size_350x350: node['src-swap-high-dpi'], size_175x175: node['src-swap']} if node
    
    ret
  end
  
  def copywright_html
    @html.css('li.copyright').text
  end
  
  def seller_url_text_html
    children = @html.css(".app-links").children
    children.select{ |c| c.text.match(/Site\z/) }.first.text
  end
  
  def support_url_text_html
    children = @html.css(".app-links").children
    children.select{ |c| c.text.match(/Support\z/) }.first.text
  end

  def dom_valid?
    attributes = self.attributes(368677368)

    ap attributes

    attributes_expected = 
      {
        name: ->(x) { x == 'Uber' },
        description: ->(x) { x.include? 'Get a reliable ride in minutes' },
        version: ->(x) { x.to_i >= 2 },
        price: ->(x) { x == 0 },
        seller_url: ->(x) { x == 'https://uber.com' },
        categories: ->(x) { x[:primary] == 'Travel'},
        size: ->(x) { x.to_i > 40e6 },
        seller: ->(x) { x == 'Uber Technologies, Inc.' },
        by: ->(x) { x == 'Uber Technologies, Inc.' },
        developer_app_store_identifier: ->(x) { x == 368677371 },
        ratings: ->(x) { x[:all][:stars] > 3.0 && x[:all][:count] > 25e3 },
        recommended_age: ->(x) { x == '4+' },
        required_ios_version: ->(x) { x.split('.').first.to_i > 2},
        first_released: -> (x) { x == Date.new(2010, 5, 21) },
        screenshot_urls: -> (x) { x.first.include?('Purple') },
        support_url: -> (x) { x.include?('help.uber') },
        released: -> (x) { date_split = x.to_s.split('-'); date_split.count == 3 && date_split.first.to_i >= 2016 },
        languages: -> (x) { (['English', 'Japanese', 'Italian'] - x).empty? },
        icon_urls: -> (x) { x.values.first.include?('Purple') },
        copywright: -> (x) { x.include?('©') }, 
        seller_url_text: -> (x) { x.include?('Uber Technologies') },
        support_url_text: -> (x) { x.include?('Support') }
      }    

    all_attributes_pass?(attributes: attributes, attributes_expected: attributes_expected)
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
    def attributes(id, country_code: 'us', lookup: true, scrape: true)
      self.new.attributes(id, country_code: country_code, lookup: lookup, scrape: scrape)
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
      links = html.css("a").select{ |a| a['href'].match(app_prefix) }.map{|a| a['href']}
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

    def dom_valid?
      self.new.dom_valid?
    end

  end

  class NotIosApp < StandardError

    def initialize(message = "This is not an iOS app")
      super
    end

  end

  class AppDoesNotExist < StandardError

    def initialize(message = "This app does not exist. Perhaps it was taken down.")
      super
    end

  end

  class BatchLookup

    MAX_APPS = 200

    def attributes(ids, country_code: 'us', skip_attributes: false)
      fail TooManyIds if ids.count > MAX_APPS

      load_json(ids: ids, country_code: country_code, unproxied: true)

      ass = AppStoreService.new

      ret = {}

      attributes = {} unless skip_attributes
      successes = []

      @json_a.each do |app_hash|

        next unless is_ios?(app_hash)

        ass.json = app_hash

        unless skip_attributes

          single_app_hash = {}

          ass.json_methods.each do |method|
            key = method.gsub(/_json\z/, '').to_sym
            
            begin
              attribute = ass.send(method.to_sym)
              single_app_hash[key] = attribute
            rescue
              single_app_hash[key] = nil
            end
          end
        end


        id = ass.app_identifier_json
        successes << id
        attributes[id] = single_app_hash unless skip_attributes
      end

      ret[:attributes] = attributes unless skip_attributes
      ret[:successes] = successes
      ret[:failures] = ids - successes
      
      ret
    end

    def load_json(ids:, country_code:, unproxied: false)
      if unproxied
        json = ItunesApi.batch_lookup(ids, country_code)
      else
        country_param = (@country_code == 'us' ? '' : "country=#{country_code}")
        ids_param = ids.join(',')
        url = "https://itunes.apple.com/lookup?id=#{ids_param}&#{country_param}"
        page = Tor.get(url)
        json = JSON.load(page)
      end
      @json_a = json['results']
    end    

    def is_ios?(app_hash)
    # wrapper type software
    # kind == 'software' (as opposed to mac-software)
      app_hash['wrapperType'] == 'software' && app_hash['kind'] == 'software'
    end

    class TooManyIds < StandardError

      def initialize(message = "iTunes only allows a look up a max of #{MAX_APPS} apps")
        super
      end

    end

    class << self

      def attributes(ids, country_code: 'us', skip_attributes: false)
        self.new.attributes(ids, country_code: country_code, skip_attributes: skip_attributes)
      end

    end

  end
end
