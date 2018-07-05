class IosDevice < ActiveRecord::Base

	has_many :class_dump
  belongs_to :apple_account
  belongs_to :softlayer_proxy
  belongs_to :open_proxy
  belongs_to :ios_device_model
  has_one :ios_device_family, through: :ios_device_model

  has_many :ios_fb_ads
  has_many :ios_fb_ad_exceptions

  has_many :fb_accounts_ios_devices
  has_many :fb_accounts, through: :fb_accounts_ios_devices

	validates :ip, uniqueness: true, allow_nil: true
	validates :serial_number, uniqueness: true, presence: true

	# either dedicated for a one off scrape or for mass scrapes
	enum purpose: [:one_off, :mass, :test, :fb_ad_scrape, :one_off_intl, :mass_intl, :fb_ad_scrape_webdriver, :scan_v2]

  # The class dump architecture to use
  # Eg. "armv7", "arm64"
  # @author Jason Lew
  def class_dump_arch
    res = ios_device_model.ios_device_family.ios_device_arch.name
    res == 'armv7s' ? 'armv7' : res
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

    def ios_version_to_fmt_version(version)
      semvers = version.split(".")
      while semvers.length < 3
        semvers << "0"
      end
      semvers.map {|d| "%03d" % d}.join(".")
    end

    def setup_device(options)
      ios_device_model = IosDeviceModel.find_by_name(options.fetch(:model_name))
      raise unless ios_device_model
      ios_version_fmt = ios_version_to_fmt_version(options.fetch(:ios_version))
      device = new(
        purpose: nil, 
        in_use: false, 
        last_used: 1.month.ago, 
        ios_device_model: ios_device_model,
        ios_version_fmt: ios_version_fmt,
        ios_version: options.fetch(:ios_version),
        ip: options.fetch(:ip),
        description: options.fetch(:description),
        serial_number: options.fetch(:serial_number))

      unless options[:skip_us_account]
        account = AppleAccount.joins('left join ios_devices on ios_devices.apple_account_id = apple_accounts.id')
          .where(app_store_id: 1) # US-only
          .where('ios_devices.id is NULL')
          .where(kind: AppleAccount.kinds[:static]).take

        device.update!(apple_account: account)
      end

      ap account
      device
    end

    def reset_helper(output_str)
      entries = output_str.split("\n")
      map = entries.reduce({}) do |memo, entry|
        parts = entry.split(':')
        memo[parts.first.to_i] = parts.second.strip
        memo
      end

      map.each do |ios_device_id, email_prefix|
        email = IosEmailAccount.create!(email: "#{email_prefix}@vfemail.net", password: "thisisapassword")
        new_apple_account = AppleAccount.create!(email: email.email, password: 'Somename1', app_store_id: 1)
        IosDevice.find(ios_device_id).update(apple_account: new_apple_account)
      end

    end
  end

end
