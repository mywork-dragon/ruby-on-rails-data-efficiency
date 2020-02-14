module AppmonstaApi
  class AppmonstaAndroidSingleResponse < AbstractSingleResponse
    # Details only present in android
    attr_accessor :app_type,
                  :contains_ads,
                  :content_rating_info,
                  :downloads,
                  :editors_choice,
                  :iap_price_range,
                  :interactive_elements,
                  :permissions,
                  :privacy_url,
                  :publisher_address,
                  :publisher_email,
                  :publisher_id_num,
                  :translated_description,
                  :video_urls

    def initialize(response_hash)
      assign_attributes(response_hash)
    end
  end
end
