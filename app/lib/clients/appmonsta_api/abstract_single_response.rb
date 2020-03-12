module AppmonstaApi
  class AbstractSingleResponse
    def initialize
      # ABSTRACT CLASS
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
end
