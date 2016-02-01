class FbActivity

  STATUS_TO_LIKE_RATIO = 1 / 30.0

  class << self

    def should_post_status?(likes_count)
      rand(0..99) < likes_count * STATUS_TO_LIKE_RATIO * 100
    end

    def browse(max_likes: 3, submit: false)

      session = Capybara::Session.new(:selenium)

      # session = if debug
      #   Capybara::Session.new(:selenium)
      # else
      #   require 'capybara/poltergeist'
      #   Capybara::Session.new(:poltergeist)
      # end

      # login
      session.visit 'https://www.facebook.com'
      session.within('#login_form') do
        session.fill_in 'email', :with => 'antoinettestephens1@openmailbox.org'
        session.fill_in 'pass', :with => 'thisisapassword'
        session.click_on('Log In')
      end

      # post a status

      if should_post_status(max_likes)
        begin
          session.find('div#pagelet_composer div.composerAudienceWrapper').click
          session.find('div#pagelet_composer div.composerAudienceWrapper').click # do this to make the text box findable....weird
          session.find('div#pagelet_composer div[spellcheck=true]').send_keys('Gym time! #girlswholift')
          button = session.find('div#pagelet_composer button[type=submit]')
          button.click if submit
          sleep 2 # sleep to let dom change
        rescue => e
          puts "failed"
        end
      end

      # like at least a couple things
      like_button_selector = '.UFILikeLink:not(.UFILinkBright)'
      likes = 0
      start = Time.now
      succeeded =  Set.new

      while Time.now - start < 60 && likes < max_likes do

        entries = session.all('.userContentWrapper').each do |entry|

          if succeeded.include?(el_to_unique_key(entry))
            puts "Skipping already completed"
            next
          end
          container = entry.native
          puts "Looking at block: #{container.location.x}, #{container.location.y}"

          begin
            button = entry.find(like_button_selector)
            session.execute_script("window.scrollTo(0, #{button.native.location.y - 100})") # make it visible and clickable
            button.click if submit
            puts "clicked"
            likes += 1
            succeeded.add(el_to_unique_key(entry))
            sleep 1.5 # sleep so that the dom can change sizes
            break
          rescue Capybara::ElementNotFound
            puts "not found"
            nil
          rescue Capybara::Ambiguous
            puts "ambiguous"
            entry.all(like_button_selector).first.click
          rescue Selenium::WebDriver::Error::UnknownError => e
            raise e unless e.message.include?('Element is not clickable')
            puts entry.visible? ? "Visible and failed" : "Not visible"
          end
        end

        # need to scroll to get more things into the feed
        session.execute_script("window.scrollBy(0, 500)")
        sleep 1 # sleep so that the dom can prefetch below the fold resources
        session.execute_script("window.scrollBy(0, 500)")
        sleep 1
      end

      puts "Likes: #{likes}"
    end


    def el_to_unique_key(el)
      location = el.native.location
      "#{location.x}-#{location.y}"
    end

    def get_status
      urls = %w(
        http://99covers.com/status/category/best-facebook-status/
        http://99covers.com/status/category/angry-facebook-status/
        http://99covers.com/status/category/facebook-status-ideas/
        http://99covers.com/status/category/wise-facebook-status/
        http://99covers.com/status/category/status-for-facebook/
        http://99covers.com/status/category/good-facebook-status/
        http://99covers.com/status/category/funny-facebook-status/
        http://99covers.com/status/category/facebook-jokes/
        http://99covers.com/status/category/amazing-facebook-status/
        http://99covers.com/status/category/sweet-facebook-status/
        http://99covers.com/status/category/friends-status/
      )

      html = Nokogiri::HTML(open(urls.sample))
      # To do later, add paging on each of the urls. Look at the span.pages
      links = html.css('section#content article.status-publish h2.entry-title>a')
      quote = links[rand(0..links.length-1)].attributes['title'].content
      quote.gsub('Permalink to', '').strip
    end

    cats = ["http://99covers.com/status/category/amazing-facebook-status/", "http://99covers.com/status/category/angry-facebook-status/", "http://99covers.com/status/category/anniversary-facebook-status/", "http://99covers.com/status/category/april-fool-status/", "http://99covers.com/status/category/best-facebook-status/", "http://99covers.com/status/category/birthday-facebook-status/", "http://99covers.com/status/category/boss-day-facebook-status/", "http://99covers.com/status/category/break-up-facebook-status/", "http://99covers.com/status/category/christmas-facebook-status/", "http://99covers.com/status/category/clever-facebook-status/", "http://99covers.com/status/category/crazy-facebook-status/", "http://99covers.com/status/category/creative-facebook-status/", "http://99covers.com/status/category/cute-facebook-status/", "http://99covers.com/status/category/daring-facebook-status/", "http://99covers.com/status/category/dirty-facebook-status/", "http://99covers.com/status/category/diwali-facebook-status/", "http://99covers.com/status/category/easter-status/", "http://99covers.com/status/category/eid-facebook-status/", "http://99covers.com/status/category/emotional-quotes-for-facebook/", "http://99covers.com/status/category/exam-status/", "http://99covers.com/status/category/facebook-condolence-message/", "http://99covers.com/status/category/facebook-crush-quotes/", "http://99covers.com/status/category/facebook-engagement-wishes/", "http://99covers.com/status/category/facebook-friendship-status/", "http://99covers.com/status/category/facebook-good-luck-messages/", "http://99covers.com/status/category/facebook-i-love-you-quotes/", "http://99covers.com/status/category/facebook-jokes/", "http://99covers.com/status/category/facebook-love-status/", "http://99covers.com/status/category/facebook-pregnancy-status/", "http://99covers.com/status/category/facebook-status/", "http://99covers.com/status/category/facebook-status-ideas/", "http://99covers.com/status/category/facebook-status-messages/", "http://99covers.com/status/category/facebook-status-quotes/", "http://99covers.com/status/category/facebook-wedding-wishes/", "http://99covers.com/status/category/facebook-wishes/", "http://99covers.com/status/category/famous-facebook-status/", "http://99covers.com/status/category/fathers-day-facebook-status/", "http://99covers.com/status/category/fb-get-well-soon-messages/", "http://99covers.com/status/category/fb-music-statuses/", "http://99covers.com/status/category/fb-status/", "http://99covers.com/status/category/flirt-facebook-status/", "http://99covers.com/status/category/friends-status/", "http://99covers.com/status/category/funny-facebook-status/", "http://99covers.com/status/category/girls-and-boys-status/", "http://99covers.com/status/category/good-facebook-status/", "http://99covers.com/status/category/good-morning-facebook-status/", "http://99covers.com/status/category/good-night-quotes-for-facebook/", "http://99covers.com/status/category/hello-facebook-status/", "http://99covers.com/status/category/hilarious-facebook-status/", "http://99covers.com/status/category/holi-status/", "http://99covers.com/status/category/independence-day-fb-status/", "http://99covers.com/status/category/insult-facebook-status/", "http://99covers.com/status/category/islamic-facebook-status/", "http://99covers.com/status/category/kids-status/", "http://99covers.com/status/category/kiss-facebook-status/", "http://99covers.com/status/category/life-status/", "http://99covers.com/status/category/love-status-for-facebook/", "http://99covers.com/status/category/missing-you-facebook-status/", "http://99covers.com/status/category/mothers-day-status/", "http://99covers.com/status/category/motivational-quotes/", "http://99covers.com/status/category/naughty-facebook-status/", "http://99covers.com/status/category/new-facebook-statuses/", "http://99covers.com/status/category/new-year-facebook-status/", "http://99covers.com/status/category/ramadan-facebook-status/", "http://99covers.com/status/category/romantic-facebook-status/", "http://99covers.com/status/category/rude-facebook-status/", "http://99covers.com/status/category/sad-facebook-status/", "http://99covers.com/status/category/sad-love-fb-status/", "http://99covers.com/status/category/selfish-facebook-status/", "http://99covers.com/status/category/sister-status/", "http://99covers.com/status/category/sorry-facebook-status/", "http://99covers.com/status/category/status-for-facebook/", "http://99covers.com/status/category/sweet-facebook-status/", "http://99covers.com/status/category/teacher-facebook-status/", "http://99covers.com/status/category/thanksgiving-fb-status/", "http://99covers.com/status/category/uncategorized/", "http://99covers.com/status/category/unique-facebook-status/", "http://99covers.com/status/category/valentine-facebook-status/", "http://99covers.com/status/category/wife-status/", "http://99covers.com/status/category/wise-facebook-status/"]

    def populate_statuses
      cats = ["http://99covers.com/status/category/amazing-facebook-status/", "http://99covers.com/status/category/angry-facebook-status/", "http://99covers.com/status/category/best-facebook-status/", "http://99covers.com/status/category/clever-facebook-status/", "http://99covers.com/status/category/crazy-facebook-status/", "http://99covers.com/status/category/creative-facebook-status/", "http://99covers.com/status/category/cute-facebook-status/", "http://99covers.com/status/category/facebook-friendship-status/", "http://99covers.com/status/category/facebook-jokes/", "http://99covers.com/status/category/facebook-status/", "http://99covers.com/status/category/facebook-status-ideas/", "http://99covers.com/status/category/facebook-status-messages/", "http://99covers.com/status/category/facebook-status-quotes/", "http://99covers.com/status/category/facebook-wishes/", "http://99covers.com/status/category/famous-facebook-status/", "http://99covers.com/status/category/fb-music-statuses/", "http://99covers.com/status/category/fb-status/", "http://99covers.com/status/category/friends-status/", "http://99covers.com/status/category/funny-facebook-status/", "http://99covers.com/status/category/good-facebook-status/", "http://99covers.com/status/category/hello-facebook-status/", "http://99covers.com/status/category/hilarious-facebook-status/", "http://99covers.com/status/category/life-status/", "http://99covers.com/status/category/motivational-quotes/", "http://99covers.com/status/category/new-facebook-statuses/", "http://99covers.com/status/category/rude-facebook-status/", "http://99covers.com/status/category/sad-facebook-status/", "http://99covers.com/status/category/selfish-facebook-status/", "http://99covers.com/status/category/status-for-facebook/", "http://99covers.com/status/category/sweet-facebook-status/", "http://99covers.com/status/category/unique-facebook-status/", "http://99covers.com/status/category/wise-facebook-status/"]
    end
  end
end