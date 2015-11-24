class IosDevice < ActiveRecord::Base

	has_many :class_dump
  belongs_to :softlayer_proxy

	validates :ip, uniqueness: true
	validates :serial_number, uniqueness: true, presence: true

	# either dedicated for a one off scrape or for mass scrapes
	enum purpose: [:one_off, :mass]

  class << self

    def create_with_proxy!(params)
      softlayer_proxies = SoftlayerProxy.all

      free_proxy = nil

      softlayer_proxies.each do |softlayer_proxy|
        if softlayer_proxy.ios_devices.empty?
          free_proxy = softlayer_proxy
          break
        end
      end

      raise 'Cannot find a free Softlayer proxy' if free_proxy.nil?

      ios_device = new(params)

      ios_device.softlayer_proxy = free_proxy

      ios_device.save!
    end

  end



end
