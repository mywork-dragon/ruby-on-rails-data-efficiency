class IosDeviceReserver

  DEFAULT_WAIT_TIME = 60 * 60 * 24 * 365 # 1 year
  DEFAULT_SLEEP_RANGE = (7...13)
  RESERVE_TYPES = {
    one_off: :immediate_reserve,
    test: :immediate_reserve,
    mass: :patient_reserve,
    fb_ad_scrape: :patient_reserve,
    one_off_intl: :immediate_reserve
  }

  attr_reader :device, :owner, :max_wait

  def initialize(owner=nil, max_wait: nil)
    @device = nil
    @owner = owner
    @max_wait = max_wait || DEFAULT_WAIT_TIME
  end

  def reserve(purpose, requirements = {})
    raise MultipleReservation if @device
    raise UnregisteredPurpose, purpose unless IosDevice.purposes[purpose] && RESERVE_TYPES[purpose]
    send(RESERVE_TYPES[purpose], purpose, requirements)
  end

  def release
    raise NoDeviceReserved if @device.nil?

    @device.in_use = false
    @device.save

    @device = nil
  end

  def has_device?
    @device.present?
  end

  # Errors

  class NoSuchDevice < StandardError
    def initialize(msg = "No devices that meet requirements")
      super(msg)
    end
  end

  class UnregisteredPurpose < StandardError
    def initialize(purpose)
      msg = "#{purpose} is not a registered purpose"
      super(msg)
    end
  end

  class UnavailableDevice < StandardError
    def initialize(msg = "Failed to reserve a device in allotted time")
      super(msg)
    end
  end

  class NoDeviceReserved < StandardError
    def initialize(msg = "No device has been reserved")
      super(msg)
    end
  end

  class InvalidRequirement < StandardError
    def initialize(msg)
      super(msg)
    end
  end

  class MultipleReservation < StandardError
    def initialize(msg = "A device has already been registered")
      super(msg)
    end
  end

  # Private methods

  private

  def immediate_reserve(purpose, requirements)
    any_exist?(purpose, requirements)

    consider_app_store = purpose == :one_off_intl

    device = try_reserve(purpose, requirements, consider_app_store: consider_app_store)

    raise UnavailableDevice if device.nil?

    device.in_use = true
    device.save

    @device = device

    nil
  end

  def patient_reserve(purpose, requirements)
    device = nil

    start_time = Time.now

    while device.nil? && Time.now - start_time < @max_wait

      any_exist?(purpose, requirements)

      puts "sleeping"
      sleep(Random.new.rand(DEFAULT_SLEEP_RANGE))

      device = try_reserve(purpose, requirements)
    end

    raise UnavailableDevice if device.nil?

    device.in_use = true
    device.save

    @device = device

    nil
  end

  def build_query(purpose, requirements, available_only: true, app_store_configured: false)
    query_parts = []

    query_parts << "id = #{requirements[:ios_device_id]}" if requirements[:ios_device_id]

    query_parts << "purpose = #{IosDevice.purposes[purpose]}"

    if available_only
      query_parts << "in_use = false"
    end
    
    # Exclude disabled devices
    query_parts << "disabled = false" unless requirements[:include_disabled]

    ### below here are constraints that do not require fresh lookups (device types, fb_account)
    ### pre build query now and join by ids to minimize time in transaction loop

    combined_id_constraints = []

    if app_store_configured
      valid_device_ids = IosDevice.joins(:apple_account).where('apple_accounts.app_store_id = ?', requirements[:app_store_id])
      raise InvalidRequirement, "No devices registered to accounts in app store #{requirements[:app_store_id]}" if valid_device_ids.blank?
      combined_id_constraints.push(valid_device_ids)
    end

    if requirements['minimumOsVersion']
      valid_device_ids = IosDevice.where("ios_version_fmt >= '#{IosDevice.ios_version_to_fmt_version(requirements['minimumOsVersion'])}'").pluck(:id)
      raise InvalidRequirement, "No devices that meet iOS version requirement #{IosDevice.ios_version_to_fmt_version(requirements['minimumOsVersion'])}" if valid_device_ids.blank?
      combined_id_constraints.push(valid_device_ids)
    end

    if requirements[:fb_account_id]
      valid_device_ids = FbAccount.find(requirements[:fb_account_id]).ios_devices.pluck(:id)
      raise InvalidRequirement, "FbAccount #{requirements[:fb_account_id]} has no attributed devices" if valid_device_ids.blank?
      combined_id_constraints.push(valid_device_ids)
    end

    if requirements['supportedDeviceTypes']
      valid_device_ids = IosDevice.joins(:ios_device_family)
        .where('ios_device_families.lookup_name in (?)', requirements['supportedDeviceTypes'])
        .pluck(:id)
      raise InvalidRequirement, "No available devices that meet required supportedDeviceType constraint" if valid_device_ids.blank?
      combined_id_constraints.push(valid_device_ids)
    end

    unless combined_id_constraints.count == 0
      intersection = combined_id_constraints.pop
      combined_id_constraints.each { |ids| intersection = intersection & ids }
      raise InvalidRequirement, "No possible devices meet all constraints" if intersection.count == 0
      query_parts << "id in (#{intersection.join(', ')})"
    end

    query_parts.join(' and ')
  end

  def try_reserve(purpose, requirements, consider_app_store: false)
    query = if consider_app_store
              begin # try to see if devices available already
                build_query(purpose, requirements, available_only: true, app_store_configured: true)
              rescue InvalidRequirement
                build_query(purpose, requirements, available_only: true) # fall back to a new device
              end
            else
              build_query(purpose, requirements, available_only: true)
            end

    IosDevice.transaction do

      d = IosDevice.lock.where(query).order(:last_used).first

      if d
        d.in_use = true
        d.last_used = DateTime.now
        d.save
      end

      d
    end
  end

  def any_exist?(purpose, requirements)
    query = build_query(purpose, requirements, available_only: false)
    puts "query: #{query}"
    any = IosDevice.where(query).take
    raise NoSuchDevice unless any
  end

  class << self

    def test
      snapshot = IpaSnapshot.last
      device_reserver = IosDeviceReserver.new
      device_reserver.reserve(:one_off, JSON.parse(snapshot.lookup_content))
      return device_reserver.device
    end
  end

end
