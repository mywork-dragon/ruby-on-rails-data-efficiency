class AppStoreIdsService

  class << self

    # helper method - opens url, returning Nokogiri object
    # def open_url(url)
    #
    #   page = open(url)
    #
    #   Nokogiri::HTML(page)
    #
    #   # Rescues error if issue opening URL
    #   rescue => e
    #     case e
    #       when OpenURI::HTTPError
    #         puts "HTTPError - could not open page"
    #         return nil
    #       when URI::InvalidURIError
    #         puts "InvalidURIError - could not open page"
    #         return nil
    #       else
    #         raise e
    #   end
    # end

    # scrapes Apple Appstore, returning Set of all unique app ids as Integers
    # example:
    # find & converts app link: "https://itunes.apple.com/us/app/clearweather-color-forecast/id550882015?mt=8"
    # into "550882015", rutrning Set of all these ids
    def scrape_app_store
      # url string param for each category of app
      app_url_ids = %w(
        ios-books/id6018
        ios-business/id6000
        ios-catalogs/id6022
        ios-education/id6017
        ios-entertainment/id6016
        ios-finance/id6015
        ios-food-drink/id6023
        ios-games/id6014
        ios-health-fitness/id6013
        ios-lifestyle/id6012
        ios-medical/id6020
        ios-music/id6011
        ios-navigation/id6010
        ios-news/id6009
        ios-newsstand/id6021
        ios-photo-video/id6008
        ios-productivity/id6007
        ios-reference/id6006
        ios-social-networking/id6005
        ios-sports/id6004
        ios-travel/id6003
        ios-utilities/id6002
        ios-weather/id6001
      )

      #app_url_ids = app_url_ids[(2..2)] #for debug, only run catalogs for now

      # url string param for each sub group of app category
      app_url_letters = ('A'..'Z').to_a + ['*']
      #app_url_letters.select!{ |l| l == 'A' } # for debug, only run letter A for now

      # for each category of app
      app_url_ids.each do |app_id|

        # for each beginning letter of app name in category
        app_url_letters.each do |app_letter|
        
          #delay.perform(app_id, app_letter) #run in background
          AppStoreIdsServiceWorker.perform_async(app_id, app_letter)
        
        end
      
      end

    end
    
  end

end

