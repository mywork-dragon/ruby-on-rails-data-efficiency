class FbStatusService
  class << self
    def populate
      cats = ["http://99covers.com/status/category/amazing-facebook-status/", "http://99covers.com/status/category/angry-facebook-status/", "http://99covers.com/status/category/best-facebook-status/", "http://99covers.com/status/category/clever-facebook-status/", "http://99covers.com/status/category/crazy-facebook-status/", "http://99covers.com/status/category/creative-facebook-status/", "http://99covers.com/status/category/cute-facebook-status/", "http://99covers.com/status/category/facebook-friendship-status/", "http://99covers.com/status/category/facebook-jokes/", "http://99covers.com/status/category/facebook-status/", "http://99covers.com/status/category/facebook-status-ideas/", "http://99covers.com/status/category/facebook-status-messages/", "http://99covers.com/status/category/facebook-status-quotes/", "http://99covers.com/status/category/facebook-wishes/", "http://99covers.com/status/category/famous-facebook-status/", "http://99covers.com/status/category/fb-music-statuses/", "http://99covers.com/status/category/fb-status/", "http://99covers.com/status/category/friends-status/", "http://99covers.com/status/category/funny-facebook-status/", "http://99covers.com/status/category/good-facebook-status/", "http://99covers.com/status/category/hello-facebook-status/", "http://99covers.com/status/category/hilarious-facebook-status/", "http://99covers.com/status/category/life-status/", "http://99covers.com/status/category/motivational-quotes/", "http://99covers.com/status/category/new-facebook-statuses/", "http://99covers.com/status/category/rude-facebook-status/", "http://99covers.com/status/category/sad-facebook-status/", "http://99covers.com/status/category/selfish-facebook-status/", "http://99covers.com/status/category/status-for-facebook/", "http://99covers.com/status/category/sweet-facebook-status/", "http://99covers.com/status/category/unique-facebook-status/", "http://99covers.com/status/category/wise-facebook-status/"]

      if Rails.env.production?
        batch = Sidekiq::Batch.new
        batch.description = "populating statuses" 
        batch.on(:complete, 'FbStatusService#on_complete')

        batch.jobs do
          cats.each do |url|
            FbStatusWorker.perform_async(url, true)
          end
        end
      else
        # just do a test one
        FbStatusWorker.new.perform(cats.sample, false)
      end
    end
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Populated Statuses', entries: FbStatus.count)
  end
end