class GooglePlayDeviceApiService
  class BadGoogleScrape < StandardError; end

  def initialize
    @google_account = GoogleAccountReserver.new.reserve(:full)
    @market_api = MightyApk::Market.new(@google_account)
    @required_keys = [:name, :released]
  end

  def get_response(app_identifier)
    @market_api.raw_app_details(app_identifier)
  rescue MightyApk::MarketApi::NotFound
    raise GooglePlayStore::NotFound
  rescue MightyApk::MarketApi::Unauthorized
    raise GooglePlayStore::Unavailable
  rescue MightyApk::MarketApi::Forbidden
    raise GooglePlayStore::Unavailable
  rescue MightyApk::MarketApi::UnsupportedCountry
    raise GooglePlayStore::Unavailable
  rescue MightyApk::MarketApi::RateLimited
    raise MightyApk::MarketApi::RateLimited
  rescue MightyApk::MarketApi::MarketError
    raise GooglePlayStore::UnknownCondition
  end

  def attributes(app_identifier, proxy_type: :general)
    ret = {}
    raw_resp = get_response(app_identifier)
    resp = raw_resp.payload.detailsResponse.docV2

    ret[:name] = resp.title
    ret[:description] = resp.descriptionHtml

    ret[:currency_code] = resp.offer[0].currencyCode
    ret[:price] = resp.offer[0].micros / 10000

    ret[:seller] = resp.creator

    ret[:seller_url] = resp.details.appDetails.developerWebsite

    ret[:permissions] = resp.details.appDetails.permission

    ret[:size] = resp.details.appDetails.installationSize

    ret[:version_code] = resp.details.appDetails.versionCode
    ret[:version] = resp.details.appDetails.versionString

    ret[:seller_email] = resp.details.appDetails.developerEmail
    ret[:seller_email] = resp.details.appDetails.developerEmail

    ret[:category_id] = resp.annotations.app_category.category_id

    ret[:released] = Date.parse(resp.details.appDetails.uploadDate)

    ret[:restriction_type] = resp.availability.restriction

    resp.more_offer_details.tags.each do |msg| 
      if msg.key == 'In-app purchases'
        ret[:in_app_purchases] = true
        ret[:in_app_purchases_range] = msg.value.value.gsub('per item', '').split(' - ').map{ |x| (x.gsub('$', '').strip.to_f*100).to_i }
      else
        ret[:in_app_purchases] = false
      end
    end

    downloads_s = resp.details.appDetails.numDownloads
    downloads_a = downloads_s.split(' - ').map{ |x| x.strip.gsub(',', '').to_i }

    ret[:downloads] = downloads_a

    ret[:content_rating] = resp.annotations.app_content_rating.rating_string


    ret[:ratings_all_stars] = resp.aggregateRating.starRating
    ret[:ratings_all_count] = resp.aggregateRating.ratingsCount
    ret[:comment_count] = resp.aggregateRating.commentCount

    links = raw_resp.payload.detailsResponse.cards.map {
        |x| {"link" => x.link.n.n.link, "name" => x.name}
      }.select {|x| !x['link'].empty?}

    sim_apps = []

    ret[:similar_apps] = []
    links.each do |link|
      sim_resp = @market_api.other(link['link'])
      if sim_resp.preFetch[0]
        similar_links = MightyApk::ProtocolBuffers::ResponseWrapper.new.parse(sim_resp.preFetch[0].response)
        if similar_links.payload.listResponse.doc[0] and similar_links.payload.listResponse.doc[0].child[0]
          ret[:similar_apps].concat(similar_links.payload.listResponse.doc[0].child[0].child.map {|x| x.docid})
        end
      end
    end

    ret[:screenshot_urls] = raw_resp.payload.detailsResponse.docV2.image.select {|x| x.imageType != 4}.map {|x| x.imageUrl}
    ret[:icon_url_300x300] = raw_resp.payload.detailsResponse.docV2.image.select {|x| x.imageType == 4}.map {|x| x.imageUrl}.first

    # Hack to pull old dev ids - but going forward we treat the seller name as the dev id.
    dev = AndroidDeveloper.find_by_name(ret[:seller])
    if dev
      ret[:developer_google_play_identifier] = dev.identifier
    else
      # Hash Synthetic identifier by sha1 of name.
      ret[:developer_google_play_identifier] = "synth-#{Digest::SHA1.hexdigest(ret[:seller])}"
    end

    @required_keys.each do |key|
      if ret[key].nil?
        raise BadGoogleScrape.new("required attribute #{key} is missing")
      end
    end
    ret
  end

  class << self

    def attributes(app_identifier, proxy_type: :general)
      self.new.attributes(app_identifier, proxy_type: proxy_type)
    end

  end
end
