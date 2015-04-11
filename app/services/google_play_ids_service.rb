class GooglePlayIdsService

  class << self

    # scrapes Google Play store
    def scrape_google_play

      # url string param for each category of app
      # @patrick You can use this syntax when you have a bunch a string literals with no spaces
      app_categories = %w(
          BOOKS
          BUSINESS
          COMICS
          COMMUNICATION
          EDUCATION
          ENTERTAINMENT
          FINANCE
          HEALTH
          LIFESTYLE
          LIVE WALLPAPER
          MEDIA
          MEDICAL
          MUSIC
          NEWS
          PERSONALIZATION
          PHOTOGRAPHY
          PRODUCTIVITY
          SHOPPING
          SOCIAL
          SPORTS
          TOOLS
          TRANSPORTATION
          TRAVEL
          WEATHER
          WIDGETS
          ARCADE
          BRAIN
          CASUAL
          CARDS
          RACING
      )

      #app_categories = app_categories[(2..2)]

      # adds alphabet nodes to array
      app_categories += ('A'..'Z').to_a
      #app_categories.select!{ |l| l == 'A' || l == 'B' } # for debug, only run letter A for now

      # for each category of app
      app_categories.each do |app_category|

        GooglePlayIdsServiceWorker.perform_async(app_category)

      end

    end
    
    def add_from_json(file)
      n = 0
      new_apps = 0
      
      File.foreach(file) do |line|
        puts "App: #{n}, New Apps: #{new_apps}" if n%10000 == 0
        
        hash = JSON.load(line)
        
        url = hash['Url']
        
        ai = url.gsub('https://play.google.com/store/apps/details?id=', '').strip
        
        aa =  AndroidApp.find_by_app_identifier(ai)
        
        if aa.nil?
          AndroidApp.create(app_identifier: ai)
          new_apps += 1
        end
        
        n += 1
      end
    end

  end

end
