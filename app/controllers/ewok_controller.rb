class EwokController < ApplicationController

  skip_before_filter  :verify_authenticity_token
  before_action :authenticate_ewok, only: [:ewok_app_page, :ewok_check_exists]
  before_action :set_current_user, only: [:ewok_app_page]

  def authenticate_ewok
    key = params['key']
    fail InvalidKey.new(key: key) unless EwokService.correct_key?(key)
  end

  # @osman
  def ewok_check_app_exists
  end

  def ewok_app_page
    # redirect to landing if app doesn't exist (if authenticate_request throws exception)
    begin 
      authenticate_request
    rescue => e
      redirect_to root_url
      return
    end

    url = params['url']
    app_url = EwokService.app_url(url)

    if app_url.nil?    
      redirect_to :currently_scraping 
      return
    end

    redirect_to app_url
    render nothing: true
  end

  class InvalidKey < StandardError
    def initialize(message = "The Ewok key is invalid.", key: nil)
      super("The Ewok key #{key} is invalid.")
    end
  end

end