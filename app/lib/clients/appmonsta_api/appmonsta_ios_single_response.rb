module AppmonstaApi
  class AppmonstaIosSingleResponse < AbstractSingleResponse
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
