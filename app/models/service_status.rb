class ServiceStatus < ActiveRecord::Base
  enum service: [:ios_live_scan, :ios_fb_ads, :ios_fb_cleaning]

  class << self
    def is_active?(service)
      row = self.find_by_service(get_info(service))
      row.active
    end

    def disable(service)
      row = self.find_by_service(get_info(service))
      row.update!(active: false)
    end

    def enable(service)
      row = self.find_by_service(get_info(service))
      row.update!(active: true)
    end

    def get_info(service)
      service_id = self.services[service]

      raise "#{service} is not a registered service" if service_id.nil?

      result = self.find_by_service(service_id)

      raise "#{service} does not have an entry in the table" if result.nil?

      service_id
    end
  end
end
