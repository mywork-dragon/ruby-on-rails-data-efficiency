class FbActivityServiceWorker

  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :kylo

  STATUS_TO_LIKE_RATIO = 1 / 200.0

  def perform(fb_activity_job_id, fb_account_id)
    begin
      account = FbAccount.find(fb_account_id)

      start = Time.now
      result = browse(account)
      duration = Time.now - start
      puts "Finished browsing account #{fb_account_id} after #{duration} seconds"
      
      FbActivity.create!({
        fb_activity_job_id: fb_activity_job_id,
        fb_account_id: fb_account_id,
        likes: result[:likes],
        status: result[:status],
        duration: duration
      })

      account.update(last_browsed: DateTime.now)
    rescue => e
      FbActivityException.create!({
        fb_activity_job_id: fb_activity_job_id,
        fb_account_id: fb_account_id,
        error: e.message,
        backtrace: e.backtrace
      })
    end
  end

  def browse(fb_account, max_likes: 3, submit: true)

    session = Capybara::Session.new(:selenium)

    # login
    session.visit 'https://www.facebook.com'
    session.within('#login_form') do
      session.fill_in 'email', :with => fb_account.username
      session.fill_in 'pass', :with => fb_account.password
      session.click_on('Log In')
    end

    # post a status
    status = nil
    if should_post_status?(max_likes)
      session.find('div#pagelet_composer div.composerAudienceWrapper').click
      session.find('div#pagelet_composer div.composerAudienceWrapper').click # do this to make the text box findable....weird
      status = get_status
      session.find('div#pagelet_composer div[spellcheck=true]').send_keys(status)
      button = session.find('div#pagelet_composer button[type=submit]')
      button.click if submit
      sleep 2 # sleep to let dom change
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

    session.driver.quit # hangs for a few seconds if unsubmitted input in the status box

    puts "Likes: #{likes}"

    {
      likes: likes,
      status: status
    }
  end

  def should_post_status?(likes_count)
    rand(0..99) < likes_count * STATUS_TO_LIKE_RATIO * 100
  end


  def el_to_unique_key(el)
    location = el.native.location
    "#{location.x}-#{location.y}"
  end

  def get_status
    r = rand(100)

    if r < 50
      get_quote
    elsif r < 90
      get_news
    else
      get_instagram
    end
  end

  def get_quote
    FbStatus.order("RAND()").first.status
  end

  def get_news
    begin
      get_link_from_rss(source_feeds.sample)
    rescue
      puts "Could not get feed from url #{url}. Reverting to quote"
      get_quote
    end
  end

  def source_feeds
    %w(
      http://www.buzzfeed.com/index.xml
    )
  end

  def get_instagram
    begin
      get_link_from_rss(File.join('http://widget.websta.me/rss/tag', hashtags.sample))
    rescue
      puts "Could not get link from url #{url}. Reverting to quote"
      get_quote
    end
  end

  def get_link_from_rss(url)
    feed = Hash.from_xml(open(url).read)
    entry = feed['rss']['channel']['item'].sample
    entry['link']
  end

  def hashtags
    %w(
      love
      cute
      happy
      beautiful
      fun
      summer
      smile
      instadaily
      fashion
      food
      happy
      foodies
    )
  end
end