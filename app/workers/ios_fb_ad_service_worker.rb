class IosFbAdServiceWorker

  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :ios_fb_ads

  def perform(ios_fb_ad_job_id, fb_account_id, bid = nil)

    unless ServiceStatus.is_active?(:ios_fb_ads)
      puts "Service is not active. Aborting"
      return
    end

    device_reserver = nil
    begin
      # reserve device
      fb_account = FbAccount.find(fb_account_id)
      device_reserver = IosDeviceReserver.new(fb_account)
      device_reserver.reserve(:fb_ad_scrape, fb_account_id: fb_account_id)
      fb_account.update(last_scraped: Time.now)

      # run the scrape
      IosFbAdDeviceService.new(ios_fb_ad_job_id, device_reserver.device, fb_account, bid: bid).start_scrape

      # release the device
      device_reserver.release
    rescue IosFbAdDeviceService::CriticalDeviceError => e
      # main difference: alert + do not "unreserve" device
      if Rails.env.production?
        device_reserver.device.update(purpose: :disabled)
        Slackiq.message("Critical Error on Device #{e.ios_device_id}. It will remain unavailable for use. Error message:\n```#{e.message}```", webhook_name: :automated_alerts)
      end

      raise e
    rescue => e
      IosFbAdException.create!({
        ios_fb_ad_job_id: ios_fb_ad_job_id,
        fb_account_id: fb_account_id,
        error: e.message,
        backtrace: e.backtrace
      })

      # release the device
      device_reserver.release if device_reserver && device_reserver.has_device?
      raise e
    end
  end
end