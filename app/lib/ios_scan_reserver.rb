# For SDK scans of apps (through IpaSnapshot)
class IosScanReserver
  class UnregisteredScanPurpose < RuntimeError; end

  def initialize(ipa_snapshot)
    @ipa_snapshot = ipa_snapshot
    @device = nil
  end

  def reserve(scan_purpose, requirements)
    type = reserve_type(scan_purpose)
  end

  def release
  end

  def us_app?
    @ipa_snapshot.app_store.country_code.upcase == 'US'
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
