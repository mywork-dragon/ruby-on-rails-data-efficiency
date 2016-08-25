class OpenProxy < ActiveRecord::Base

  enum kind: [:digital_ocean_squid]

  class << self

    def create_digital_ocean_squid!(public_ip:)
      params = {public_ip: public_ip, username: 'ms_open_proxy', password: '7CjnctEFkL9yvVCwEUd3VkHyiG8g2M', port: 3128, kind: :digital_ocean_squid}
      self.create!(params)
    end

  end

end
