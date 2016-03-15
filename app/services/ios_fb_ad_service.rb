class IosFbAdService
  class << self

    def begin_scraping
      return "Don't run this in development" if Rails.env.development?

      unless ServiceStatus.is_active?(:ios_fb_ads)
        puts "Service is not active. Aborting"
        return
      end

      ios_fb_ad_job = IosFbAdJob.create!(notes: "Running scrape at #{Time.now.strftime '%m/%d/%Y %H:%M %Z'}")

      batch = Sidekiq::Batch.new
      batch.description = 'iOS Facebook Ad Spend'
      batch.on(:complete, 'IosFbAdService#on_complete', 'job_id' => ios_fb_ad_job.id)

      batch.jobs do
        FbAccount.where(flagged: false).each do |fb_account|
          IosFbAdServiceWorker.perform_async(ios_fb_ad_job.id, fb_account.id, batch.bid)
        end
      end

    end

    def cycle_fb_accounts(ios_device_id)
      FbAccount.all.each do |fb_account|
        puts "Trying account #{fb_account.username}"
        IosFbAdDeviceService.new(IosDevice.find(ios_device_id), fb_account).cycle_account
      end
    end
  end

  def on_complete(status, options)
    ios_fb_ad_job = IosFbAdJob.find(options['job_id'])

    Slackiq.notify(webhook_name: :debug,
      status: status,
      title: 'Completed iOS Facebook ad spend scrape',
      'Job Id' => ios_fb_ad_job.id,
      '# of Ads Found' => ios_fb_ad_job.ios_fb_ads.count,
      '# of Ads Completed' => ios_fb_ad_job.ios_fb_ads.where(status: IosFbAd.statuses[:complete]).count,
      'Exceptions' => ios_fb_ad_job.ios_fb_ad_exceptions.count
    )
  end
end