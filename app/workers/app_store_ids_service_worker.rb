class AppStoreIdsServiceWorker
  include Sidekiq::Worker

  def perform(app_id, app_letter)
    app_ids = Set.new
  
    last_page = false

    page_num = 0
  
    while !last_page 

      page_num += 1

      logger.info "SCRAPING    CATEGORY: " + app_id + "    SUB GROUP: " + app_letter + "    PAGE: " + page_num.to_s + "..."
       
        # Compiles link for page of app list
        # Example: https://itunes.apple.com/us/genre/ios-weather/id6001?mt=8&letter=C&page=2
        dom = open_url("https://itunes.apple.com/us/genre/" + app_id + "?letter=" + app_letter + "&page=" + page_num.to_s)

        if dom != nil

          # wrapper for #selectedcontent columns
          results = dom.css("#selectedcontent > div.column")

          # iterate over each of the result wrapper elements
          results.each do |result|

          links = result.css("ul > li").css("a")

          # if number of app links on page is 1 or 0, last page has been reached
          if links.length < 2
              last_page = true # stops loop upon next iteration
          end

          # finds the href link inside the <a> and strips out the id, casting it to an Integer
          # Before: "https://itunes.apple.com/us/app/clearweather-color-forecast/id550882015?mt=8"
          # After: 550882015
          links.map { |link| app_ids << link['href'].gsub('?mt=8','').split('id').last.to_i }
      
        end
      
      end
    
      add_to_db(app_ids.to_a)
    
    end
  end
  
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
  
  # Pass array of app ids to add to db
  def add_to_db(app_ids)
  
    app_ids.each do |app_id|
    
      ios_app = IosApp.find_by_app_identifier(app_id)
    
      if ios_app.nil?
        ios_app = IosApp.new(app_identifier: app_id)
        app = App.create
        ios_app.app = app
        success = ios_app.save
        
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