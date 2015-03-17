class AppStoreIdsService

  class << self

    # helper method - opens url, returning Nokogiri object
    def open_url(url)

      page = open(url)

      Nokogiri::HTML(page)

      # Rescues error if issue opening URL
      rescue => e
        case e
          when OpenURI::HTTPError
            puts "HTTPError - could not open page"
            return nil
          when URI::InvalidURIError
            puts "InvalidURIError - could not open page"
            return nil
          else
            raise e
      end
    end

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
  
    # def perform(app_id, app_letter)
    #   #SidekiqTester.create!(test_string: "#{app_id} #{app_letter}", ip: MyIp.ip)
    #
    #   app_ids = Set.new
    #
    #   last_page = false
    #
    #   page_num = 0
    #
    #   while !last_page
    #
    #     page_num += 1
    #
    #     puts "SCRAPING    CATEGORY: " + app_id + "    SUB GROUP: " + app_letter + "    PAGE: " + page_num.to_s + "..."
    #
    #       # Compiles link for page of app list
    #       # Example: https://itunes.apple.com/us/genre/ios-weather/id6001?mt=8&letter=C&page=2
    #       dom = open_url("https://itunes.apple.com/us/genre/" + app_id + "?letter=" + app_letter + "&page=" + page_num.to_s)
    #
    #       if dom != nil
    #
    #         # wrapper for #selectedcontent columns
    #         results = dom.css("#selectedcontent > div.column")
    #
    #         # iterate over each of the result wrapper elements
    #         results.each do |result|
    #
    #         links = result.css("ul > li").css("a")
    #
    #         # if number of app links on page is 1 or 0, last page has been reached
    #         if links.length < 2
    #             last_page = true # stops loop upon next iteration
    #         end
    #
    #         # finds the href link inside the <a> and strips out the id, casting it to an Integer
    #         # Before: "https://itunes.apple.com/us/app/clearweather-color-forecast/id550882015?mt=8"
    #         # After: 550882015
    #         links.map { |link| app_ids << link['href'].gsub('?mt=8','').split('id').last.to_i }
    #
    #       end
    #
    #     end
    #
    #     add_to_db(app_ids.to_a)
    #
    #   end
    # end
  
    # # Pass array of app ids to add to db
    # def add_to_db(app_ids)
    #
    #   app_ids.each do |app_id|
    #
    #     ios_app = IosApp.find_by_app_identifier(app_id)
    #
    #     if ios_app.nil?
    #       ios_app = IosApp.new(app_identifier: app_id)
    #       app = App.create
    #       ios_app.app = app
    #       success = ios_app.save
    #
    #     else
    #       li "IosApp #{app_id} already in db"
    #     end
    #
    #   end
    #
    #
    # end
    
  end

end

