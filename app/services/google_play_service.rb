class GooglePlayService
  include AppAttributeChecker

  class BadGoogleScrape < RuntimeError
    def initialize(app_identifier, attrs)
      msg = "#{app_identifier} invalid attributes: #{attrs}"
      super(msg)
    end
  end

  def self.attributes(app_identifier)
    response = AppmonstaApi::Base.get_single_app_attributes(:android, app_identifier)
    AndroidMapper.new(response).to_h
  end

  # alias to_h
  def get_mapped_hash



    # methods.each do |method|
    #   key = method.to_sym
    #
    #   next if key == :in_app_purchases_range && !ret[:in_app_purchases]
    #
    #   begin
    #     attribute = send(method.to_sym)
    #     ret[key] = attribute
    #   rescue
    #     ret[key] = nil
    #   end
    # end

    # Added to prevent bad snaps from getting into DB.
    incorrect = validate_attrs(ret)
    if incorrect.present?
      raise BadGoogleScrape.new(app_identifier, incorrect)
    end

    ret
  end

  private

  def validate_attrs(res)
    failed_attributes = []
    failed_attributes << :name unless res[:name].present?
    failed_attributes << :released if res[:released].nil?
    failed_attributes << :category_id unless res[:category_id].present?
    failed_attributes << :developer_google_play_identifier unless res[:developer_google_play_identifier].present?
    failed_attributes << :description if res[:description].nil?
    failed_attributes << :seller unless res[:seller].present?
    if d = res[:downloads]
      failed_attributes << :downloads if d.min.nil? || d.max.nil?
    end
    if res[:similar_apps].present?
      failed_attributes << :similar_apps if res[:similar_apps].select { |x| /[^\w.]/.match(x) }.present?
    end
    failed_attributes
  end

end
