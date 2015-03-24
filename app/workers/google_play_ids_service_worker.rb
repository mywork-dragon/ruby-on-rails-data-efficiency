class GooglePlayIdsServiceWorker
  include Sidekiq::Worker

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

  def perform(app_category)

    app_ids = Set.new

    logger.info "SCRAPING    CATEGORY: " + app_category + "..."

    # Open initial page
    apps_page_dom = open_url("https://play.google.com/store/search?q=" + app_category + "&c=apps&ipf=1&xhr=1")

    if apps_page_dom != nil

      pag_token = ""

      while pag_token != nil  #becomes nil when hit the end of async loading

        # wrapper for #selectedcontent columns
        app_cards = apps_page_dom.css("div.card-list > div.card")

        # iterate over each of the result wrapper elements
        app_cards.each do |app_card|

          # finds the href link inside the <a> and strips out the id
          # Before: "/store/apps/details?id=com.hottrix.ibeerfree"
          # After: "com.hottrix.ibeerfree"
          #app_id = app_card.css("a.card-click-target")['href'].split('id=').last

          app_ids.add(app_card.css("a.card-click-target").first['href'].split('id=').last)

        end

        # Regex parses HTML document, finding the pagTok (page token)
        pag_token_array = apps_page_dom.to_html.match(/GAEi+.+\:S\:.{11}\\42/)

        if pag_token_array != nil
          # Cleans up pagTok, returning ready-for-use string
          pag_token = pag_token_array[0].gsub(':S:','%3AS%3A').gsub("\\42",'').gsub("\\u003d",'').gsub("\\", "=").split(',').last

          page_url = "https://play.google.com/store/search?q=" + app_category + "&c=apps&start=0&num=0&numChildren=0&pagTok=" + pag_token + "&ipf=1&xhr=1"

          # Open initial page
          apps_page_dom = open_url(page_url)

        else
          pag_token = nil
        end

      end

    end

    add_to_db(app_ids.to_a)

  end

  # Pass array of app ids to add to db
  def add_to_db(app_ids)

    app_ids.each do |app_id|

      android_app = AndroidApp.find_by_app_identifier(app_id)

      if android_app.nil?
        android_app = AndroidApp.new(app_identifier: app_id)
        app = App.create
        android_app.app = app
        success = android_app.save

        if success
          logger.info "#{app_id} added to DB"
        else
          logger.error "Failed to save #{app_id} to DB"
        end

      else
        logger.info "IosApp #{app_id} already in db"
      end

    end


  end

end