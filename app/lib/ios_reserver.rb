# Reserves a device and account
# Could reserve more things too in the future
# @author Jason Lew
class IosReserver

  RESERVE_TYPES = [
    :one_off, # US or intl
    :test, 
    :mass,
    :fb_ad_scrape
  ] 

  attr_reader :device, :apple_account

  def initialize(ios_app:, app_store:)
    fail IosAppBlank if ios_app.blank?
    fail AppStoreBlank if app_store.blank?

    @ios_app = ios_app
    @app_store = app_store

    @device_reserver = nil
    @apple_account_reserver = nil

    @device = nil
    @apple_account = nil

    @a_device_already_configured = false

    @released = false
  end

  def reserve(purpose, requirements)

    if purpose == :one_off
      if us_app?
        reserve_device_flex_account_static(requirements)
      else
        reserve_device_flex_account_flex(requirements)
      end
    elsif [:test, :mass, :fb_ad_scrape].include?(purpose)
      reserve_device_flex_account_static(requirements)
    end
  end

  def reserve_device_flex_account_static(requirements)
    puts "reserve_device_flex_account_static"
    @a_device_already_configured = true

    @device_reserver = IosDeviceReserver.new
    @device_reserver.reserve(:one_off, requirements)
    @device = @device_reserver.device

    apple_account = @device.apple_account
    fail NoStaticAccount if apple_account.blank?
    @apple_account = apple_account

    true
  end

  def reserve_device_flex_account_flex(requirements)
    puts "reserve_device_flex_account_flex"
    return true if a_device_already_configured_correctly?

    @device_reserver = IosDeviceReserver.new
    @device_reserver.reserve(:one_off_intl, requirements)
    @device = @device_reserver.device

    @apple_account_reserver = AppleAccountReserver.new(ios_app: @ios_app, app_store: @app_store)
    @apple_account_reserver.reserve(:one_off_intl, requirements)
    @apple_account = @apple_account_reserver.apple_account

    true
  end

  # Call this on the isntance once the account has actually been changed
  def account_changed
    @apple_account.ios_device = @device
    @apple_account.save
  end

  # Whether the app is in the USA app store
  def us_app?
    @app_store.country_code.upcase == 'US'
  end

  # For flex/flex only
  def a_device_already_configured_correctly?
    ios_device = nil
    blank_device = nil

    IosDevice.transaction do
      ios_device = IosDevice.lock.joins(:apple_account).where(purpose: IosDevice.purposes[:one_off_intl], in_use: false, disabled: false).where("apple_accounts.app_store_id = ?", @app_store.id).limit(1).first

      blank_device = ios_device.blank?
      
      unless blank_device
        ios_device.in_use = true
        ios_device.save
      end
    end
    
    return false if blank_device

    @device = ios_device
    @apple_account = ios_device.apple_account
    @a_device_already_configured = true

    true
  end

  def a_device_already_configured?
    !!@a_device_already_configured
  end

  def release
    fail AlreadyReleased if @released

    if @apple_account
      @apple_account.ios_device = nil
      @apple_account.save

      # nil out all accounts devices since only one account per phone at a time
      if @device
        AppleAccount.where(ios_device: @device).each do |apple_account|
          apple_account.ios_device = nil
          apple_account.save
        end
      end

    end

    @device_reserver.release if @device_reserver && @device
    @apple_account_reserver.release if @apple_account_reserver && @apple_account
    @released = true
  end

  def released?
    @released
  end

  # Errors

  class IosAppBlank < StandardError
    def initialize(msg = "ios_app is blank")
      super(msg)
    end
  end

  class AppStoreBlank < StandardError
    def initialize(msg = "app_store is blank")
      super(msg)
    end
  end

  class AlreadyReleased < StandardError
    def initialize(msg = "#{self.class} instance has already been released.")
      super(msg)
    end
  end

  class NoStaticAccount < StandardError
    def initialize(msg = "Device should have static account, be there's no account in the DB.")
      super(msg)
    end
  end


  class << self

    def setup_test
      us = AppStore.find_or_create_by(country_code: 'US', enabled: true)
      cn = AppStore.find_or_create_by(country_code: 'CN', enabled: true)
      au = AppStore.find_or_create_by(country_code: 'AU', enabled: true)
      ru = AppStore.find_or_create_by(country_code: 'RU', enabled: true)

      AppleAccount.find_or_create_by(email: "hotandsoursoup@openmailbox.org", password: 'Somename1', app_store: cn, kind: :flex, in_use: false) #CN
      AppleAccount.find_or_create_by(email: "frank.wong2@openmailbox.org", password: 'Somename1', app_store: cn, kind: :flex, in_use: false) #CN
      AppleAccount.find_or_create_by(email: "simon.hailey2@openmailbox.org", password: 'Somename1', app_store: au, kind: :flex, in_use: false)  #AU
      AppleAccount.find_or_create_by(email: "julia.fuchs3@openmailbox.org", password: 'Somename1', app_store: ru, kind: :flex, in_use: false)   #RU

      5.times do
        ios_device = IosDevice.create(ip: SecureRandom.hex, serial_number: SecureRandom.hex, purpose: :one_off_intl)
      end
      
      ios_app = IosApp.create(app_identifier: 123456789)
      ios_app.app_stores += [cn, au, ru]
      ios_app.save
    end

    def test_us_app
      setup_test

      us = AppStore.find_by_country_code('us')

      ios_app = IosApp.find_or_create_by(app_identifier: rand(5e3) + 1)
      ios_app.app_stores << us

      ios_device = IosDevice.create(ip: SecureRandom.hex, serial_number: SecureRandom.hex, purpose: :one_off, in_use: false)
      ios_device.apple_account = AppleAccount.create(email: "america@openmailbox.org", password: 'Somename1', app_store: us, kind: :static)

      ios_reserver = self.new(ios_app: ios_app)
      ios_reserver.reserve(:one_off, {ios_device_id: ios_device.id})

      ios_reserver
    end

    def test_one_off_device_already_configured
      setup_test

      simon = AppleAccount.where(email: "simon.hailey2@openmailbox.org").first

      ios_device = IosDevice.create(ip: SecureRandom.hex, serial_number: SecureRandom.hex, purpose: :one_off_intl, in_use: false)
      ios_device.apple_account = simon
      ios_device.save

      ios_app = IosApp.find_by_app_identifier(123456789)

      ios_reserver = self.new(ios_app: ios_app)
      ios_reserver.reserve(:one_off, nil)

      ios_reserver
    end

    def test_account_flex
      setup_test

      # 10.times do
      #   ios_device = IosDevice.create(ip: SecureRandom.hex, serial_number: SecureRandom.hex, purpose: :one_off_intl, in_use: false)
      # end

      ios_device = IosDevice.create(ip: '192.168.2.116', serial_number: 'wlaksfnlasnf', purpose: :one_off_intl, in_use: false)

      cn = AppStore.find_by_country_code('CN')
      au = AppStore.find_by_country_code('AU')

      ios_app = IosApp.find_or_create_by(app_identifier: 368677368) # uber
      ios_app.app_stores += [cn, au]
      ios_app.save


      ios_reserver = self.new(ios_app: ios_app)
      ios_reserver.reserve(:one_off, {})

      ios_reserver
    end

  end

end
