# For SDK scans of apps (through IpaSnapshot)
class IosScanReserver
  class UnregisteredScanPurpose < RuntimeError; end
  class InvalidInput < RuntimeError; end
  class UnknownCondition < RuntimeError; end

  def initialize(ipa_snapshot)
    @ipa_snapshot = ipa_snapshot
    @device_reserver = IosDeviceReserver.new(self)
    @swap_required = false
  end

  def reserve(scan_purpose, requirements)
    type = reserve_type(scan_purpose)
    @device_reserver.reserve(type, requirements)
    setup_app_store_account(type, requirements[:app_store_id])
  end

  def setup_app_store_account(reserve_type, app_store_id)
    raise InvalidInput unless device && app_store_id
    existing_apple_account = device.apple_account
    @apple_account = if existing_apple_account && existing_apple_account.app_store_id == app_store_id
                       puts 'correctly configured'
                       existing_apple_account
                       @swap_required = false
    else
      raise UnknownCondition unless is_flex_type?(reserve_type)
      # get apple account
      @swap_required = true
    end
    @apple_account.update!(last_used: Time.now)
  end

  def device
    @device_reserver.device if @device_reserver
  end

  def correct_app_store?
  end
  
  def apple_account
  end

  def release
  end

  def us_app?
    @ipa_snapshot.app_store.country_code.upcase == 'US'
  end

  def is_flex_type?(reserve_type)
    [:one_off_intl].include?(reserve_type)
  end

  def reserve_type(scan_purpose)
    if purpose == :one_off
      us_app? ? :one_off : :one_off_intl
    elsif [:test, :mass].include?(purpose)
      purpose
    else
      raise UnregisteredScanPurpose
    end
  end
end
