class IosDevice < ActiveRecord::Base

	has_many :class_dump
  belongs_to :softlayer_proxy

	validates :ip, uniqueness: true
	validates :serial_number, uniqueness: true, presence: true

	# either dedicated for a one off scrape or for mass scrapes
	enum purpose: [:one_off, :mass]

  # Eg. "armv7", "arm64"
  def class_dump_arch 
  end

  # Eg. "4S", "5"
  def model_name 
  end
    
  end

  class << self

    # Helper method to create new device with proxy
    def create_with_proxy!(params)
      transaction do

        free_proxy = nil

        SoftlayerProxy.all.each do |softlayer_proxy|
          if softlayer_proxy.ios_devices.blank?
            free_proxy = softlayer_proxy
            break
          end
        end

        raise 'Cannot find a free Softlayer proxy' if free_proxy.nil?

        ios_device = new(params)

        ios_device.softlayer_proxy = free_proxy

        ios_device.save!

        email = nil
        google_account_password = nil

        GoogleAccount.all.each do |google_account|
          if AppleAccount.where(email: google_account.email).blank?
            email = google_account.email
            google_account_password = google_account.password
            break
          end
        end

        raise 'Cannot find a free email address from google_accounts table' if email.nil?

        apple_account = AppleAccount.create!(email: email, password: 'Somename1', ios_device: ios_device)

        ap apple_account

        puts "Gmail password: #{google_account_password}".purple

        puts "Proxy IP: #{ios_device.softlayer_proxy.public_ip}"

        ios_device
      end


    end



  end



end
