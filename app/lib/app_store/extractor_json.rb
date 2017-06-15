require_relative 'extractor_base'

module AppStoreHelper
  class ExtractorJson < AppStoreHelper::ExtractorBase

    class NotIosApp < RuntimeError; end

    attr_reader :data

    # Used in determining the etag of the snapshot. If any of these
    # columns change after scanning the EPF we'll add a new snapshot
    # of the app into the snapshots table.
    SIGNIFICANT_KEYS = [
      'artistId',
      'collectionId',
      'trackId',
      'trackName',
      'description',
      'releaseNotes',
      'version',
      'price',
      'sellerUrl',
      'primaryGenreName',
      'genres',
      'fileSizeBytes',
      'artistId',
      'trackContentRating',
      'minimumOsVersion',
      'releaseDate',
      'screenshotUrls',
      'currentVersionReleaseDate',
      'averageUserRatingForCurrentVersion',
      'userRatingCountForCurrentVersion',
      'averageUserRating',
      'userRatingCount',
      'artworkUrl512',
      'artworkUrl100',
      'artworkUrl60',
      'bundleId',
      'sellerName',
      'isGameCenterEnabled',
      'currency',
      'primaryGenreId'
    ]

    def initialize(lookup_json)
      @data = lookup_json
    end

    def verify_ios!
      raise NotIosApp if @data['wrapperType'] != 'software' || @data['kind'] != 'software'
    end

    # sometimes we get non ios things in our DB that dont have track ids...
    #
    def alternate_identifier
      collection_identifier || artist_identifier
    end

    def artist_identifier
      @data['artistId']
    end

    def collection_identifier
      @data['collectionId']
    end

    def app_identifier
      @data['trackId']
    end

    def name
      @data['trackName']
    end

    def description
      @data['description']
    end

    def release_notes
      @data['releaseNotes']
    end

    def version
      @data['version']
    end

    def price
      (@data['price'].to_f*100.0).to_i
    end

    def seller_url
      @data['sellerUrl']
    end

    def category_names
      primary = @data['primaryGenreName']
      all_cats = @data['genres']

      secondary = all_cats - [primary]
      
      {primary: primary, secondary: secondary}
    end

    def size
      @data['fileSizeBytes']
    end

    def developer_app_store_identifier
      @data['artistId']
    end

    def recommended_age
      @data['trackContentRating']
    end

    def required_ios_version
      @data['minimumOsVersion']
    end

    def first_released
      @data['releaseDate'].to_date
    end

    def screenshot_urls
      @data['screenshotUrls']
    end

    def released
      @data['currentVersionReleaseDate'].to_date
    end

    def ratings_current_stars
      @data['averageUserRatingForCurrentVersion'].to_f
    end

    def ratings_current_count
      @data['userRatingCountForCurrentVersion'].to_i
    end

    def ratings_all_stars
      @data['averageUserRating'].to_f
    end

    def ratings_all_count
      @data['userRatingCount'].to_i
    end

    def icon_url_512x512
      @data['artworkUrl512']
    end

    def icon_url_100x100
      @data['artworkUrl100']
    end

    def icon_url_60x60
      @data['artworkUrl60']
    end

    def game_center_enabled
      @data['isGameCenterEnabled']
    end

    def bundle_identifier
      @data['bundleId']
    end

    def currency
      @data['currency']
    end

    def seller_name
      @data['sellerName']
    end

    def category_ids
      primary = @data['primaryGenreId']
      all_cats = @data['genreIds'].map(&:to_i)
      
      secondary = all_cats - [primary]
      
      {primary: primary, secondary: secondary}
    end

    def etag
      md5 = Digest::MD5.new
      SIGNIFICANT_KEYS.each do |key|
        md5 << @data[key].to_s
      end
      md5.hexdigest
    end
  end
end
