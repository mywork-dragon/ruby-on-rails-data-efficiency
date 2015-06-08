class AppStoreIdsService

  class << self

    # scrapes Apple Appstore, returning Set of all unique app ids as Integers
    # example:
    # find & converts app link: "https://itunes.apple.com/us/app/clearweather-color-forecast/id550882015?mt=8"
    # into "550882015", rutrning Set of all these ids
    def run(country_code)
      # url string param for each category of app

      app_store = AppStore.find_by_country_code(country_code)
      raise 'App Store not in DB' if app_store.nil?
      app_store_id = app_store.id

      app_url_ids = app_url_ids(country_code)

      #app_url_ids = app_url_ids[(2..2)] #for debug, only third for now

      # url string param for each sub group of app category
      app_url_letters = ('A'..'Z').to_a + ['*']
      #app_url_letters.select!{ |l| l == 'G' } # for debug, only run one letter for now

      # for each category of app
      app_url_ids.each do |app_id|

        # for each beginning letter of app name in category
        app_url_letters.each do |app_letter|
        
          #delay.perform(app_id, app_letter) #run in background
          # AppStoreIdsServiceWorker.perform_async(app_id, app_letter)
          AppStoreIdsServiceWorker.new.perform(app_id, app_letter, app_store_id)
        end
      
      end

    end
    
    def app_url_ids(country_code)
    
      case country_code
      when 'us'
        %w(
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
      when 'jp'
        %w(
          ios-bukku/id6018
          ios-bijinesu/id6000
          ios-katarogu/id6022
          ios-jiao-yu/id6017
          ios-entateinmento/id6016
          ios-fainansu/id6015
          ios-fudo-dorinku/id6023
          ios-gemu/id6014
          ios-herusukea-fittonesu/id6013
          ios-raifusutairu/id6012
          ios-medikaru/id6020
          ios-myujikku/id6011
          ios-nabigeshon/id6010
          ios-nyusu/id6009
          ios-newsstand/id6021
          ios-xie-zhen-bideo/id6008
          ios-shi-shi-xiao-lu-hua/id6007
          ios-ci-shu-ci-dian-sono-ta/id6006
          ios-sosharunettowakingu/id6005
          ios-supotsu/id6004
          ios-lu-xing/id6003
          ios-yutiriti/id6002
          ios-tian-qi/id6001
        )
      else
        raise 'Invalid country_code'
      end
    
    end
    
  end
  


end

