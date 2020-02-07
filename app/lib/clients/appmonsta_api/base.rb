module AppmonstaApi
  class Base

    include HTTParty

    BASE_URI = ENV['APPMONSTA_BASE_URI'].freeze
    PORT = ENV['APPMONSTA_BASE_PORT'] || 80
    BASIC_AUTH = {username: ENV['APPMONSTA_USER'], password: ''} #Currently doesn't use password

    base_uri BASE_URI

    def self.get_single_app_attributes(platform, app_identifier, country='ALL')
      case platform.to_s
      when 'android'
        response = get_single_app_details(:android, app_identifier, country)
        AppmonstaAndroidSingleResponse.new(response.parsed_response)
      when 'ios'
        response = get_single_app_details(:itunes, app_identifier, country)
        AppmonstaIosSingleResponse.new(response.parsed_response)
      else
        raise StandardError.new("Platform not provided or wrong")
      end
    end


    private

    def self.get_single_app_details(platform, app_identifier, country)
      raise StandardError.new("Platform not allowed: #{platform}") unless %i(android itunes).include?(platform)
      get("/stores/#{platform}/details/#{app_identifier}.json?country=#{country}", basic_auth: BASIC_AUTH)
    end

    def self.get_io_details(app_identifier, country)
      get("/stores/ios/details/#{app_identifier}.json?country=#{country}", basic_auth: BASIC_AUTH)
    end



    class AbstractSingleResponse

      def initialize
        raise StandardError.new("Abstract")
      end
      # Common details
      attr_accessor :all_histogram,
      :all_rating,
      :all_rating_count,
      :app_name,
      :bundle_id,
      :content_rating,
      :description,
      :file_size,
      :genre,
      :genre_id,
      :genres,
      :genre_ids,
      :icon_url,
      :id,
      :price,
      :price_currency,
      :price_value,
      :publisher_id,
      :publisher_name,
      :publisher_url,
      :related,
      :release_date,
      :requires_os,
      :screenshot_urls,
      :status,
      :status_date,
      :status_unix_timestamp,
      :store_url,
      :top_developer,
      :version,
      :whats_new

      private
      def assign_attributes(new_attributes)
        new_attributes.each { |key, value| public_send("#{key}=", value) }
      end

    end


    class AppmonstaAndroidSingleResponse < AppmonstaApi::AbstractSingleResponse
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

    class AppmonstaIosSingleResponse < AppmonstaApi::AbstractSingleResponse
      # Details only present in ios
      attr_accessor :ll_reviews,
      :urrent_histogram,
      :urrent_rating,
      :urrent_rating_count,
      :urrent_reviews,
      :ile_size_bytes,
      :as_game_center,
      :n_app_purchases,
      :s_universal,
      :anguages,
      :equires_hardware,
      :eller,
      :upport_url

      def initialize(response_hash)
        assign_attributes(response_hash)
      end
    end
  end
end
