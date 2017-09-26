# DEPRECATED - 9/25/2017
class IosFbCleaningService

  class << self

    def clean_devices

      return "Don't run this in development" if Rails.env.development?

      unless ServiceStatus.is_active?(:ios_fb_cleaning)
        puts "Service is not active. Aborting"
        return
      end
      
      ios_fb_ad_job = IosFbAdJob.create!(job_type: :clean, notes: "Cleaning phones at #{Time.now.strftime '%m/%d/%Y %H:%M %Z'}")
      
      disabled_devices_count = IosDevice.where(purpose: IosDevice.purposes[:fb_ad_scrape], disabled: true).count

      batch = Sidekiq::Batch.new
      batch.description = 'iOS FB Device Cleaning'
      batch.on(:complete, 'IosFbCleaningService#on_complete', 'job_id' => ios_fb_ad_job.id, 'disabled_count_before' => disabled_devices_count)

      batch.jobs do
        IosDevice.where(purpose: IosDevice.purposes[:fb_ad_scrape]).each do |ios_device|
          IosFbCleaningServiceWorker.perform_async(ios_fb_ad_job.id, ios_device.id)
        end
      end

    end

  end

  def on_complete(status, options)
    ios_fb_ad_job = IosFbAdJob.find(options['job_id'])
    disabled_count_before = options['disabled_count_before']

    Slackiq.notify(webhook_name: :background,
      status: status,
      title: 'Completed iOS FB Device Cleaning',
      'Job Id' => ios_fb_ad_job.id,
      'Exceptions' => ios_fb_ad_job.ios_fb_ad_exceptions.count,
      'Disabled Device Before' => disabled_count_before,
      'Disabled Devices Remaining' => IosDevice.where(purpose: IosDevice.purposes[:fb_ad_scrape], disabled: true).count
    )
  end

end
