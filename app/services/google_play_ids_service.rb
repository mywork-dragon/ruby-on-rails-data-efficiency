class GooglePlayIdsService

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

    # scrapes Google Play store
    def scrape_app_store

      # app_ids = Set.new # @patrick Ruby style usually uses underscore naming conventions for local vars :)

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

      app_categories = app_categories[(2..2)] #for debug, only run catalogs for now

      # adds alphabet nodes to array
      app_categories += ('A'..'Z').to_a
      app_categories.select!{ |l| l == 'A' } # for debug, only run letter A for now

      # for each category of app
      app_categories.each do |app_category|

        # logger.info "SCRAPING    CATEGORY: " + app_category + "..."

        puts "SCRAPING    CATEGORY: " + app_category + "..."

        # response    = server.Post (String.Format (https://play.google.com/store/search?q={0}&c=apps, searchField), ipf=1&xhr=1);

        # Open initial page
        apps_page_dom = open_url("https://play.google.com/store/search?q=" + app_category + "&c=apps&ipf=1&xhr=1")

        if apps_page_dom != nil

          pag_token = ""

          while pag_token != nil

            # wrapper for #selectedcontent columns
            app_cards = apps_page_dom.css("div.card-list > div.card")

            # iterate over each of the result wrapper elements
            app_cards.each do |app_card|

              # finds the href link inside the <a> and strips out the id
              # Before: "/store/apps/details?id=com.hottrix.ibeerfree"
              # After: "com.hottrix.ibeerfree"
              #app_id = app_card.css("a.card-click-target")['href'].split('id=').last

              app_id = app_card.css("a.card-click-target").first['href'].split('id=').last

              puts "\n" + app_id

            end

            # Regex parses HTML document, finding the pagTok (page token)
            pag_token_array = apps_page_dom.to_html.match(/GAEi+.+\:S\:.{11}\\42/)

            puts pag_token

            puts pag_token_array.inspect

            if pag_token_array != nil
              # Cleans up pagTok, returning ready-for-use string
              pag_token = pag_token_array[0].gsub(':S:','%3AS%3A').gsub('\\42','').gsub('\\u003d','')
            else
              pag_token = nil
            end

            puts pag_token

            page_url = "https://play.google.com/store/search?q=" + app_category + "&c=apps&start=0&num=0&numChildren=0&pagTok=" + pag_token + "&ipf=1&xhr=1"

            puts page_url

            # Open initial page
            apps_page_dom = open_url(page_url)

            puts apps_page_dom

          end

        end

      end

    end

  end

end
