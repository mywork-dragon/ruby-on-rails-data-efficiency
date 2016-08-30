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
    website = Website.find(website_id)
    duplicates = Website.where(url: website.url)
    fail 'No duplicates found' unless duplicates.count > 1

    primary_website = choose_primary_website(duplicates)
    to_remove = duplicates.select { |x| x.id != primary_website.id }.map(&:id)

    IosAppsWebsite.where(website_id: to_remove).update_all(website_id: primary_website.id)
    AndroidAppsWebsite.where(website_id: to_remove).update_all(website_id: primary_website.id)
    IosDevelopersWebsite.where(website_id: to_remove).update_all(website_id: primary_website.id)
    AndroidDevelopersWebsite.where(website_id: to_remove).update_all(website_id: primary_website.id)
    WebsiteDomainDatum.where(website_id: to_remove).delete_all
    Website.where(id: to_remove).delete_all
  end

  def choose_primary_website(options)
    primary = options.find { |x| x.company_id }
    return primary if primary

    options.sort.first
  end

  def on_complete_fix_websites(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Fixed websites')
  end
end
