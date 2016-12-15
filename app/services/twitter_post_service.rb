# Posts a msg and GIF to Twitter
class TwitterPostService

  TWITTER_CHARACTER_LIMIT = 140
  POST_GIF_TRIES = 3
  GOOGLE_KEY = ENV['GOOGLE_URL_SHORTENER_KEY'].to_s

  INSTALL_SEARCH_TERMS = %w(
    hooray
    congratulations
    party
    fantastic
    awesome
  )

  ENTERED_SEARCH_TERMS = %w(
    victory
    winner
    smile
    amazing
    wow
  )

  def run(activity)
    activity_type = activity.activity_type.to_sym

    post = if activity_type == :install
      generate_install_post(activity)
    elsif activity_type == :entered_top_apps
      generate_entered_top_apps_post(activity)
    end

    if post.present?
      post(status: post[:status], gif_search_term: post[:gif_search_term])
    else
      "Not valid"
    end
  end

  def generate_install_post(activity)
    ios_app = nil
    ios_sdk = nil

    activity.owners.each do |owner|
      if owner.class == IosApp
        ios_app = owner
      elsif owner.class == IosSdk
        ios_sdk = owner
      end
    end

    return {} if [ios_app, ios_sdk].include?(nil)

    install_action_content(ios_app: ios_app, ios_sdk: ios_sdk)
  end

  def install_action_content(ios_app:, ios_sdk:)
    ios_app_twitter_handle = ios_app.twitter_handles.first.try(:handle)

    ios_app_name = ios_app_name_truncated(ios_app)
    
    ios_sdk_twitter_handle = ios_sdk.twitter_handles.first.try(:handle)

    return {} if ios_sdk_twitter_handle.blank? || ios_app_name.blank?

    ios_sdk_name = ios_sdk.name

    statuses = [
      "#{ios_sdk_name} is now installed in #{ios_app_name}. Congrats!",
      "We noticed that #{ios_sdk_name} is now installed in #{ios_app_name}!",
      "Hey #{ios_sdk_name}, you're now installed in #{ios_app_name}!"
    ]

    handles = [ios_sdk_twitter_handle, ios_app_twitter_handle].compact.map{ |h| "@#{h}" }.join(' ')
    status = statuses.sample 
    status += " #{handles}" if handles.present?
    status += " #{Googl.shorten(ios_app.app_store_link, nil, GOOGLE_KEY).short_url}" if status.length <= 110

    {status: status, gif_search_term: INSTALL_SEARCH_TERMS.sample}
  end

  def generate_entered_top_apps_post(activity)
    ios_app = nil
    ios_app_ranking = nil

    activity.owners.each do |owner|
      if owner.class == IosApp
        ios_app = owner
      elsif owner.class == IosAppRanking
        ios_app_ranking = owner
      end
    end

    return {} if [ios_app, ios_app_ranking].include?(nil)

    entered_action_content(ios_app: ios_app, ios_app_ranking: ios_app_ranking)
  end

  def entered_action_content(ios_app:, ios_app_ranking:)
    ios_app_twitter_handle = ios_app.twitter_handles.first.try(:handle)

    ios_app_name = ios_app_name_truncated(ios_app)

    return {} if ios_app_name.blank?

    rank = ios_app_ranking.rank

    statuses = [
      "Hey, #{ios_app_name}, you entered the Top 200 in the App Store and are at ##{rank}!",
      "Congrats #{ios_app_name}! You entered the Top 200 in the App Store! You're at ##{rank}!"
    ]

    handles = [ios_app_twitter_handle].compact.map{ |h| "@#{h}" }.join(' ')
    status = statuses.sample
    status += " #{handles}" if handles.present?
    status += " #{Googl.shorten(ios_app.app_store_link, nil, GOOGLE_KEY).short_url}" if status.length <= 110

    {status: status, gif_search_term: INSTALL_SEARCH_TERMS.sample}
  end

  def ios_app_name_truncated(ios_app)
    ios_app.name.split(' ').first(5).join(' ') if ios_app.name
  end

  def post(status:, gif_search_term:)
    status = status[0..(TWITTER_CHARACTER_LIMIT - 1)]
    gif_url = GiphyService.gif(gif_search_term)

    if gif_url
      try = 0
      begin
        MightyBot.new.post_status_with_gif(text: status, gif_url: gif_url)
      rescue => e
        if (try += 1) < POST_GIF_TRIES
          retry
        else
          MightyBot.new.post_status(status) #post without gif
        end
      end
    else
      MightyBot.new.post_status(status)
    end
    
  end

  class << self

    def run(activity)
      self.new.run(activity)
    end

    def post(status:, gif_search_term:)
      self.new.post(status: status, gif_search_term: gif_search_term)
    end

    def test
      self.post(status: "Welcome y'all!", gif_search_term: "angry")
    end

  end

end
