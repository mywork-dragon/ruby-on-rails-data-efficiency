class WebsiteFixWorker
  include Sidekiq::Worker

  sidekiq_options queue: :sdk, retry: false

  def perform(method, *args)
    send(method, *args)
  end

  def queue_websites
    batch = Sidekiq::Batch.new
    batch.description = "AppStoreInternationalService.run_snapshots" 
    batch.on(
      :complete,
      'WebsiteFixWorker#on_complete_fix_websites'
    )

    batch.jobs do
      Website.select('id, url, count(*)').group(:url).having('count(*) > 1').map do |website|
        WebsiteFixWorker.perform_async(:fix_website, website.id)
      end
    end
  end

  def fix_website(website_id)
    puts website_id
  end

  def on_complete_fix_websites
    Slackiq.notify(webhook_name: :main, status: status, title: 'Fixed websites')
  end
end
