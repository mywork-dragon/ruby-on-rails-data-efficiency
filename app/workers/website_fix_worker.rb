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

    # should not just update...should delete the old one and ensure the new one is created
    fix_join(IosAppsWebsite, to_remove, primary_website)
    fix_join(AndroidAppsWebsite, to_remove, primary_website)
    fix_join(IosDevelopersWebsite, to_remove, primary_website)
    fix_join(AndroidDevelopersWebsite, to_remove, primary_website)
    fix_join(WebsiteDomainDatum, to_remove, primary_website)

    Website.where(id: to_remove).delete_all
  end

  def fix_join(model, to_remove, primary)
    model.where(website_id: to_remove).update_all(website_id: primary.id)
    # remove duplicates
    duplicates = model.where(website_id: primary.id)
    return unless duplicates.length > 1
    chosen_id = duplicates.first.id
    model.where(website_id: primary.id).where.not(id: chosen_id).delete_all
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
