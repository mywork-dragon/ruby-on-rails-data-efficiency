class IosDevice < ActiveRecord::Base

	has_many :class_dump
  belongs_to :softlayer_proxy
  belongs_to :ios_device_model

	validates :ip, uniqueness: true
	validates :serial_number, uniqueness: true, presence: true

	# either dedicated for a one off scrape or for mass scrapes
	enum purpose: [:one_off, :mass]

  # The class dump architecture to use
  # Eg. "armv7", "arm64"
  # @author Jason Lew
  def class_dump_arch
    ios_device_model.ios_device_family.ios_device_arch.name
  end

  # The device family name
  # Eg. "iPhone 4S", "iPhone 5"
  # @author Jason Lew
  def device_family_name
    ios_device_model.ios_device_family.name 
  end

  # Helper method to assign model
  # @author Jason Lew
  # @param model_name eg. A1533
  def assign_model(model_name)
    self.ios_device_model = self.class.check_for_model_name(model_name)
    save!
  end


  class << self

    # Helper method to create new device with proxy
    def create_with_proxy!(params)
      transaction do

        model_name = params[:model_name]

        ios_device_model = check_for_model_name(model_name)

        params.delete(:model_name)

        free_proxy = nil

        SoftlayerProxy.all.each do |softlayer_proxy|
          if softlayer_proxy.ios_devices.blank?
            free_proxy = softlayer_proxy
            break
          end
        end

        raise 'Cannot find a free Softlayer proxy' if free_proxy.nil?

        ios_device = new(params.merge(ios_device_model: ios_device_model))

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

    # Check if the model name is in the DB
    # @author Jason Lew
    def check_for_model_name(model_name)
      ios_device_model = IosDeviceModel.find_by_name(model_name)

      raise "Could not find model #{model_name} in DB. Add it to the DB if it's a new model." if ios_device_model.nil?

      ios_device_model
    end



  end



end
