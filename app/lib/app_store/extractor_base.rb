module AppStoreHelper
  class ExtractorBase

    class Unimplemented < RuntimeError; end

    def initialize(data)
      @data = data
    end

    def app_identifier
      raise Unimplemented
    end

    def name
      raise Unimplemented
    end

    def description
      raise Unimplemented
    end

    def release_notes
      raise Unimplemented
    end

    def version
      raise Unimplemented
    end

    def price
      raise Unimplemented
    end

    def seller_url
      raise Unimplemented
    end

    def categories
      raise Unimplemented
    end

    def size
      raise Unimplemented
    end

    def seller
      raise Unimplemented
    end

    def by
      raise Unimplemented
    end

    def developer_app_store_identifier
      raise Unimplemented
    end

    def ratings
      raise Unimplemented
    end

    def recommended_age

      raise Unimplemented
    end

    def required_ios_version
      raise Unimplemented
    end

    def first_released
      raise Unimplemented
    end

    def screenshot_urls
      raise Unimplemented
    end

    def released
      raise Unimplemented
    end

    def ratings_current_stars
      raise Unimplemented
    end

    def ratings_current_count
      raise Unimplemented
    end

    def ratings_all_stars
      raise Unimplemented
    end

    def ratings_all_count
      raise Unimplemented
    end

    def icon_url_512x512
      raise Unimplemented
    end

    def icon_url_100x100
      raise Unimplemented
    end

    def icon_url_60x60
      raise Unimplemented
    end

    def game_center_enabled
      raise Unimplemented
    end

    def bundle_identifier
      raise Unimplemented
    end

    def currency
      raise Unimplemented
    end

    def category_ids
      raise Unimplemented
    end

    ####### HTML only methods ########
    def support_url
      raise Unimplemented
    end

    def languages
      raise Unimplemented
    end

    def in_app_purchases
      raise Unimplemented
    end

    def editors_choice
      raise Unimplemented
    end

    def copywright
      raise Unimplemented
    end

    def seller_url_text
      raise Unimplemented
    end

    def support_url_text
      raise Unimplemented
    end

    def icon_urls
      raise Unimplemented
    end

  end
end
