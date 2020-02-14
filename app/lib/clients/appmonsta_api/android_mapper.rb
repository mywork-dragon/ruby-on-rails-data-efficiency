module AppmonstaApi
  class AndroidMapper

    FIELDS_MAP = {
      name:                                       :app_name,
      description:                                :description,
      seller:                                     :publisher_name,
      seller_url:                                 :publisher_url,
      seller_email:                               :publisher_email,
      category_name:                              :genre_id,
      price:                                      :price,
      category_id:                                :genre_id,
      released:                                   :release_date,
      size:                                       :file_size,
      top_dev:                                    :top_developer,
      in_app_purchases:                           :iap_price_range,
      in_app_purchases_range:                     :iap_price_range,
      required_android_version:                   :requires_os,
      version:                                    :version,
      downloads:                                  :downloads,
      content_rating:                             :content_rating,
      ratings_all_stars:                          :all_rating,
      ratings_all_count:                          :all_rating_count,
      similar_apps:                               :related,
      screenshot_urls:                            :screenshot_urls,
      icon_url_300x300:                           :icon_url,
      developer_google_play_identifier:           :publisher_id
    }.freeze


    attr_reader :response

    def initialize(response)
      @response = AppmonstaAndroidSingleResponse.new(response)
    end



    def to_h
      FIELDS_MAP.inject({}) do | memo, (k,v) |
        memo[k] = send("mapped_#{k}".to_sym)
        memo
      end
    end


    private

    # Fields that need any transformation before presented
    CUSTOM_FIELDS = %i(
      size
      date
      released
      in_app_purchases
      in_app_purchases_range
      downloads
      similar_apps
    )

    (FIELDS_MAP.keys - CUSTOM_FIELDS).each do |f|
      define_method("mapped_#{f}") do
        response.send FIELDS_MAP[f]
      end
    end

    def mapped_size
      size_text = response.send(FIELDS_MAP[:size])
      if size_text == "Varies with device"
        nil
      else
        Filesize.from(size_text + "iB").to_i # iB added to string to interface with filesize Gem convention
      end
    end

    def mapped_released
      date_text = response.send(FIELDS_MAP[:released])
      date = Date.parse(date_text.to_s) rescue nil

      if date.andand.future?
        Rails.logger.error('Date is the future')
        return nil
      end

      date
    end

    def mapped_in_app_purchases
      mapped_in_app_purchases_range.to_s.present?
    end

    def mapped_in_app_purchases_range
      iap_s = response.send(FIELDS_MAP[:in_app_purchases])
      return unless iap_s.present?
      iap_a = iap_s.gsub('per item', '').split(' - ').map{ |x| (x.gsub('$', '').strip.to_f*100).to_i }
      return iap_a[0]..iap_a[1]
    end

    def mapped_downloads
      downloads_s = response.send(FIELDS_MAP[:downloads])
      min = downloads_s.strip.gsub(/[\+,]/, '').to_i

      # infer max for now. it's order of magnitude / 2
      # 100+ = 1000..5000
      # 5000+ = 5000..10000
      max = 10**(Math.log10(min).floor + 1)
      max = max / 2 == min ? max : max / 2
      min..max
    rescue
      nil
    end

    def mapped_similar_apps
      all_related = response.send(FIELDS_MAP[:similar_apps])
      all_related.andand["related_apps"] ? all_related["related_apps"] : []
    end

  end
end
