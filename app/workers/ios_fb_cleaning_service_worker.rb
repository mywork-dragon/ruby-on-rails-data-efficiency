# DEPRECATED - 9/25/2017
class IosFbCleaningServiceWorker

  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :ios_fb_ads

  def perform(ios_fb_ad_job_id, ios_device_id)

    ios_device = IosDevice.find(ios_device_id)
    device_reserver = IosDeviceReserver.new(ios_device)
    device_reserver.reserve(:fb_ad_scrape, ios_device_id: ios_device_id, include_disabled: true)

    unless ServiceStatus.is_active?(:ios_fb_cleaning)
      puts "Service is not active. Aborting"
      return
    end

    IosFbAdDeviceService.new(ios_fb_ad_job_id, device_reserver.device).clean

  rescue => e
    puts "Device #{ios_device_id} failed cleaning, will not re-enable" if ios_device.disabled
    # raise e # throw for sidekiq monitoring
  else
    if ios_device.disabled
      puts "Re-enabling device #{ios_device_id} after successful cleaning"
      ios_device.update(disabled: false)
    end
  ensure
    device_reserver.release if device_reserver && device_reserver.has_device?
  end
end
