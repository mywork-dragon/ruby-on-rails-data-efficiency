class OpenProxy < ActiveRecord::Base

  enum kind: [:digital_ocean_squid, :digital_ocean_tinyproxy]

  has_many :ios_devices
  has_many :ios_fb_ads

  class << self

    def create_digital_ocean_squid!(public_ip:)
      params = {public_ip: public_ip, username: 'ms_open_proxy', password: '7CjnctEFkL9yvVCwEUd3VkHyiG8g2M', port: 3128, kind: :digital_ocean_squid}
      self.create!(params)
    end

    def create_digital_ocean_tinyproxy!(public_ip:)
      params = {public_ip: public_ip, port: 8888, kind: :digital_ocean_tinyproxy}
      self.create!(params)
    end

  end

end
