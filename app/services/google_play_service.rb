class GooglePlayService
  include AppAttributeChecker

  class BadGoogleScrape < RuntimeError
    def initialize(app_identifier, attrs)
      msg = "#{app_identifier} invalid attributes: #{attrs}"
      super(msg)
    end
  end

  class << self
    def single_app_details(app_identifier)
      response = AppmonstaApi::Base.get_single_app_details(:android, app_identifier)
      details_hash = AppmonstaApi::AndroidMapper.new(response).to_h
      validate_details!(app_identifier, details_hash)
      details_hash
    end

    private

    def validate_details!(app_identifier, res)
      failed_attributes = []
      failed_attributes << :name unless res[:name].present?
      failed_attributes << :released if res[:released].blank?
      failed_attributes << :category_id unless res[:category_id].present?
      failed_attributes << :developer_google_play_identifier unless res[:developer_google_play_identifier].present?
      failed_attributes << :description if res[:description].blank?
      failed_attributes << :seller unless res[:seller].present?

      d = res[:downloads]
      unless d &&
        d.is_a?(Range) &&
        d.min.present? &&  #nil if min == max
        d.max.present?
        failed_attributes << :downloads
      end

      if failed_attributes.present?
        raise BadGoogleScrape.new(app_identifier, failed_attributes)
      end
    end
  end
end
