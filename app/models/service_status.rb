class ServiceStatus < ActiveRecord::Base
  enum service: [
    :ios_live_scan,
    :ios_fb_ads,
    :ios_fb_cleaning,
    :ios_international_live_scan,
    :android_live_scan,
    :auto_ios_mass_scan,
    :auto_ios_us_scrape,
    :auto_ios_intl_scrape,
    :ios_auto_sdk_creation,
    :clearbit_contact_service,
    :general_maintenance,
    :ios_v1_download,
    :ios_v2_download
  ]

  class << self
    def is_active?(service)
      row = self.find_by_service(get_info(service))
      row ? row.active : false
    end

    def disable(service)
      row = self.find_by_service(get_info(service))
      row.update!(active: false)
    end

    def enable(service)
      row = self.find_by_service(get_info(service))
      if row.nil?
        row = ServiceStatus.create(:service => service)
      end
      row.update!(active: true)
    end

    def get_info(service)
      service_id = self.services[service]

      raise "#{service} is not a registered service" if service_id.nil?

      result = self.find_by_service(service_id)

      service_id
    end

    def enable_notice
      puts "Enter a message:"
      message = gets.chomp
      service = self.find_by_service(get_info(:general_maintenance))
      service.update_attributes(:outage_message => message, :active => true)
    end

    def disable_notice
      service = self.find_by_service(get_info(:general_maintenance))
      service.update_attribute(:active, false)
    end

  end
end
