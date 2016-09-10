# For SDK scans of apps (through IpaSnapshot)
class IosScanReserver
  class UnregisteredScanPurpose < RuntimeError; end
  class InvalidInput < RuntimeError; end
  class UnknownCondition < RuntimeError; end
  class NoAccountAvailable < RuntimeError; end
  class UnreservedState < RuntimeError; end

  def initialize(ipa_snapshot)
    @ipa_snapshot = ipa_snapshot
    @device_reserver = IosDeviceReserver.new(self)
    @released = false
  end

  def reserve(scan_purpose, requirements)
    type = reserve_type(scan_purpose)
    @device_reserver.reserve(type, requirements)
    setup_app_store_account(type, requirements[:app_store_id])
  end

  def setup_app_store_account(reserve_type, app_store_id)
    raise InvalidInput unless device && app_store_id
    existing_account = device.apple_account
    @apple_account = if existing_account && existing_account.app_store_id == app_store_id
                       puts 'correctly configured'
                       @swap_required = false
                       existing_account
                     else
                       raise UnknownCondition unless is_flex_type?(reserve_type)
                       @swap_required = true
                       pick_flex_apple_account(app_store_id)
                     end
    @apple_account.update!(last_used: Time.now)
  end

  def device
    @device_reserver.device if @device_reserver
  end

  # Can have one account on multiple devices. no "reserving"
  def pick_flex_apple_account(app_store_id)
    account = AppleAccount.transaction do
      a = AppleAccount.where(
        app_store_id: app_store_id,
        kind: AppleAccount.kinds[:flex]
      ).limit(1).order(last_used: :DESC).take
    end
    raise NoAccountAvailable unless account
    account
  end
  
  def apple_account
    @apple_account
  end

  def released?
    @released
  end

  def release
    raise MultipleReleases if @released
    @device_reserver.release if device
    @released = true
  end

  def us_app?
    @ipa_snapshot.app_store.country_code.upcase == 'US'
  end

  def is_flex_type?(reserve_type)
    [:one_off_intl].include?(reserve_type)
  end

  def reserve_type(scan_purpose)
    if scan_purpose == :one_off
      us_app? ? :one_off : :one_off_intl
    elsif [:test, :mass].include?(scan_purpose)
      scan_purpose
    else
      raise UnregisteredScanPurpose
    end
  end

  def account_changed
    device.update!(apple_account: apple_account)
  end

  def is_swap_required?
    raise UnreservedState unless !!defined?(@swap_required)
    @swap_required
  end

  class << self
    def test_scaffolding
      IosDevice.update_all(in_use: false)
      AppStore.find_or_create_by!(id: 1, country_code: 'us')
      AppStore.find_or_create_by!(id: 2, country_code: 'jp')
      aa_us = AppleAccount.find_or_create_by!(id: 1, app_store_id: 1, kind: AppleAccount.kinds[:static])
      aa_jp = AppleAccount.find_or_create_by!(id: 2, app_store_id: 2, kind: AppleAccount.kinds[:flex])
      IosDevice.where(
        purpose: [
          IosDevice.purposes[:one_off],
          IosDevice.purposes[:mass]
        ]
      ).update_all(apple_account_id: aa_us)
    end

    def test_us_one_off
      test_scaffolding
      ipa_snapshot = IpaSnapshot.create!(app_store_id: 1)
      requirements = {
        app_store_id: 1
      }
      reserver = new(ipa_snapshot)
      reserver.reserve(:one_off, requirements)
      raise unless reserver.device && reserver.device.purpose == 'one_off' && reserver.device.in_use == true
      raise unless reserver.apple_account && reserver.apple_account.app_store_id == 1
      raise unless reserver.is_swap_required? == false
      reserver
    end

    def test_mass
      test_scaffolding
      ipa_snapshot = IpaSnapshot.create!(app_store_id: 1)
      requirements = {
        app_store_id: 1
      }
      reserver = new(ipa_snapshot)
      reserver.reserve(:mass, requirements)
      raise unless reserver.device && reserver.device.purpose == 'mass' && reserver.device.in_use == true
      raise unless reserver.apple_account && reserver.apple_account.app_store_id == 1
      raise unless reserver.is_swap_required? == false
      reserver
    end

    def test_intl_one_off
      test_scaffolding
      IosDevice.joins(:apple_account).where('apple_accounts.app_store_id = ?', 2).update_all(apple_account_id: nil)

      ipa_snapshot = IpaSnapshot.create!(app_store_id: 2)
      requirements = {
        app_store_id: 2
      }

      # reserve two devices one after another with the same country code despite 1 account
      reserver1 = new(ipa_snapshot)
      reserver1.reserve(:one_off, requirements)
      raise unless reserver1.device && reserver1.device.purpose == 'one_off_intl' && reserver1.device.in_use == true
      raise unless reserver1.apple_account && reserver1.apple_account.app_store_id == 2
      raise unless reserver1.is_swap_required? == true

      reserver2 = new(ipa_snapshot)
      reserver2.reserve(:one_off, requirements)
      raise unless reserver2.device && reserver2.device.purpose == 'one_off_intl' && reserver2.device.in_use == true
      raise unless reserver2.apple_account && reserver2.apple_account.app_store_id == 2
      raise unless reserver2.is_swap_required? == true

      # test releases
      d1_id = reserver1.device.id
      d2_id = reserver2.device.id
      reserver1.release
      reserver2.release
      raise if IosDevice.where(id: [d1_id, d2_id], in_use: true).any?

      # now test if already configured
      aa = AppleAccount.where(app_store_id: 2).limit(1).take
      IosDevice.where(purpose: 4, in_use: false).update_all(apple_account_id: nil)
      dd = IosDevice.where(purpose: 4, in_use: false).take
      dd.update!(apple_account: aa)
      reserver1 = new(ipa_snapshot)
      reserver1.reserve(:one_off, requirements)
      raise unless reserver1.device && reserver1.device.purpose == 'one_off_intl' && reserver1.device.in_use == true && reserver1.device.id == dd.id
      raise unless reserver1.apple_account && reserver1.apple_account.app_store_id == 2
      raise unless reserver1.is_swap_required? == false # <----
    end
  end
end
