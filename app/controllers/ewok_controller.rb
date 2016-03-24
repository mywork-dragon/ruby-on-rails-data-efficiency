class EwokController < ApplicationController

  skip_before_filter  :verify_authenticity_token
  before_action :authenticate_ewok, only: [:ewok_app_page]

  def authenticate_ewok
    key = params['key']
    fail InvalidKey.new(key: key) unless EwokService.correct_key?(key)
  end

  def ewok_app_page
    url = params['url']
    app_url = EwokService.app_url(url)

    if app_url.nil?    
      redirect_to 'http://apple.com' 
      return
    end

    puts "good"

    redirect_to app_url
  end

  class InvalidKey < StandardError
    def initialize(message = "The Ewok key is invalid.", key: nil)
      super("The Ewok key #{key} is invalid.")
    end
  end

end