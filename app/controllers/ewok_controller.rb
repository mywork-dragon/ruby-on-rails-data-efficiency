class EwokController < ApplicationController

  skip_before_filter  :verify_authenticity_token
  before_action :authenticate_ewok, only: [:ewok_app_page]

  def authenticate_ewok
    key = params['key']
    fail InvalidKey.new(key: key) unless EwokService.correct_key?(key)
  end

  def ewok_app_page
    url = params['url']

    begin
      app_url = EwokService.app_url(url)
      redirect_to root_url if app_url.nil?
    rescue EwokService::AppNotInDb => e
      EwokService.scrape_async(app_identifier: e.app_identifier, store: e.store)
      redirect_to action: 'scanning_app' 
      return
    end

    redirect_to app_url
  end

  def scanning_app
  end

  class InvalidKey < StandardError
    def initialize(message = "The Ewok key is invalid.", key: nil)
      super("The Ewok key #{key} is invalid.")
    end
  end

end