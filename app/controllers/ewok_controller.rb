class EwokController < ApplicationController

  skip_before_filter  :verify_authenticity_token
  before_action :authenticate_ewok, only: [:ewok_app_page]

  layout "marketing" 

  def authenticate_ewok
    key = params['key']
    fail InvalidKey.new(key: key) unless EwokService.correct_key?(key)
  end

  def ewok_app_page
    url = params['url']

    begin
      app_url = EwokService.app_url(url)
      redirect_to app_url + "?from=ewok" if app_url
    rescue EwokService::AppNotInDb => e
      EwokService.scrape_async(app_identifier: e.app_identifier, store: e.store)
      EwokService.scrape_international_async(app_identifier: e.app_identifier, store: e.store) if e.store == :ios
    end
  end

  class InvalidKey < StandardError
    def initialize(message = "The Ewok key is invalid.", key: nil)
      super("The Ewok key #{key} is invalid.")
    end
  end

end
