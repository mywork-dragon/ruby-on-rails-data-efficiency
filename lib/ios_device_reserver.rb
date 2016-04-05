class IosDeviceReserver

  DEFAULT_WAIT_TIME = 60 * 60 * 24 * 365 # 1 year
  DEFAULT_SLEEP_RANGE = (7...13)
  RESERVE_TYPES = {
    one_off: :immediate_reserve,
    test: :immediate_reserve,
    mass: :patient_reserve,
    fb_ad_scrape: :patient_reserve # switch to patient reserve later
  }

  attr_reader :device, :owner, :max_wait

  def initialize(owner, max_wait = nil)
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
    query = build_query(purpose, requirements)

    any_exist?(purpose, requirements)

    device = try_reserve(purpose, requirements)

    raise UnavailableDevice if device.nil?

    device.in_use = true
    device.save

    @device = device

    nil
  end

  def patient_reserve(purpose, requirements)
    query = build_query(purpose, requirements)

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

  def build_query(purpose, requirements, available_only: true)
    query_parts = []

    query_parts << "purpose = #{IosDevice.purposes[purpose]}"

    if available_only
      query_parts << "in_use = false"
    end
    
    # Exclude disabled devices
    query_parts << "disabled = false"

    # custom hooks
    if requirements['minimumOsVersion']
      query_parts << "ios_version_fmt >= '#{IosDevice.ios_version_to_fmt_version(requirements['minimumOsVersion'])}'"
    end

    if requirements[:fb_account_id]
      valid_device_ids = FbAccount.find(requirements[:fb_account_id]).ios_devices.pluck(:id)
      raise InvalidRequirement, "FbAccount #{requirements[:fb_account_id]} has no attributed devices" if valid_device_ids.blank?
      query_parts << "id in (#{valid_device_ids.join(', ')})"
    end

    query_parts.join(' and ')
  end

  def try_reserve(purpose, requirements)
    query = build_query(purpose, requirements, available_only: true)
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
    any = IosDevice.where(query).take
    raise NoSuchDevice unless any
  end

end
