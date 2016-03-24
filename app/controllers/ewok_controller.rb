class EwokController < ActionController::Base

  skip_before_filter  :verify_authenticity_token
  before_action :authenticate_ewok only: [:ewok_app_page, :ewok_check_exists]

  def authenticate_ewok
    fail InvalidKey.new(key: key) unless EwokService.correct_key?(key)
  end

  # @osman
  def ewok_check_app_exists
    
  end

  def ewok_app_page

    render json: EwokService.app_page.to_json
  end

  class InvalidKey < StandardError
    def initialize(message = "The Ewok key is invalid.", key: nil)
      super("The Ewok key #{key}is invalid.")
    end
  end

end