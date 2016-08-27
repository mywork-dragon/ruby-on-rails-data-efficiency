# Reserver an account (for :flex accounts only, not :static)
# Called from IosDeviceReserver
# Only do immediate reservation
class AppleAccountReserver

  DEFAULT_WAIT_TIME = 60 * 60 * 24 * 365 # 1 year
  DEFAULT_SLEEP_RANGE = (7...13)

  RESERVE_TYPES = {
    one_off_intl: :immediate_reserve,
    mass_intl: :patient_reserve
  }

  attr_reader :apple_account, :max_wait

  def initialize(ios_app:, app_store:, max_wait: nil)
    fail IosAppBlank if ios_app.blank?
    fail AppStoreBlank if app_store.blank?

    @ios_app = ios_app
    @app_store = app_store
    @apple_account = nil
    @max_wait = max_wait || DEFAULT_WAIT_TIME
  end

  def reserve(purpose, requirements = {})
    fail MultipleReservation if @apple_account
    fail UnregisteredPurpose, purpose unless IosDevice.purposes[purpose] && RESERVE_TYPES[purpose]
    send(RESERVE_TYPES[purpose], purpose, requirements)
  end

  def release
    fail NoAccountReserved if @apple_account.nil?

    @apple_account.in_use = false
    @apple_account.save

    @apple_account = nil
  end


  # Errors

  class NoSuchAccount < StandardError
    def initialize(msg = "No accounts that meet requirements")
      super(msg)
    end
  end

    class UnregisteredPurpose < StandardError
    def initialize(purpose)
      msg = "#{purpose} is not a registered purpose"
      super(msg)
    end
  end

  class UnavailableAccount < StandardError
    def initialize(msg = "Failed to reserve an account")
      super(msg)
    end
  end

  class NoAccountReserved < StandardError
    def initialize(msg = "No account has been reserved")
      super(msg)
    end
  end

  class InvalidRequirement < StandardError
    def initialize(msg)
      super(msg)
    end
  end

  class MultipleReservation < StandardError
    def initialize(msg = "An account has already been registered")
      super(msg)
    end
  end

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

  private 

  def immediate_reserve(purpose, requirements)
    any_exist?(purpose, requirements)

    apple_account = try_reserve(purpose, requirements)

    fail UnavailableAccount if apple_account.nil?

    apple_account.in_use = true
    apple_account.save

    @apple_account = apple_account

    nil
  end

  # untested
  def patient_reserve(purpose, requirements)
    apple_account = nil

    start_time = Time.now

    while apple_account.nil? && Time.now - start_time < @max_wait

      any_exist?(purpose, requirements)

      sleep_s = Random.new.rand(DEFAULT_SLEEP_RANGE)
      puts "sleeping for #{'%.2f' % sleep}s"
      sleep(sleep_s)

      apple_account = try_reserve(purpose, requirements)
    end

    raise UnavailableDevice if apple_account.nil?

    apple_account.in_use = true
    apple_account.save

    @apple_account = apple_account

    nil
  end

  def build_query(purpose, requirements, available_only: true)
    query_parts = []

    query_parts << "kind = #{AppleAccount.kinds[:flex]}"

    query_parts << "app_store_id = #{@app_store.id}"

    if available_only
      query_parts << "in_use = false"
    end

    query_parts.join(' and ')
  end

  def try_reserve(purpose, requirements)
    query = build_query(purpose, requirements)

    AppleAccount.transaction do

      a = AppleAccount.lock.where(query).order(:last_used).first

      if a
        a.in_use = true
        a.last_used = DateTime.now
        a.save
      end

      a
    end
  end

  def any_exist?(purpose, requirements)
    query = build_query(purpose, requirements, available_only: false)
    puts "query: #{query}"
    any = AppleAccount.where(query).take
    raise NoSuchAccount unless any
  end

  class << self

    def test
      cn = AppStore.find_or_create_by(country_code: 'CN')
      au = AppStore.find_or_create_by(country_code: 'AU')
      ru = AppStore.find_or_create_by(country_code: 'RU')

      AppleAccount.find_or_create_by(email: "hotandsoursoup@openmailbox.org", password: 'Somename1', app_store: cn, kind: :flex) #CN
      AppleAccount.find_or_create_by(email: "frank.wong2@openmailbox.org", password: 'Somename1', app_store: cn, kind: :flex) #CN
      AppleAccount.find_or_create_by(email: "simon.hailey2@openmailbox.org", password: 'Somename1', app_store: au, kind: :flex)  #AU
      AppleAccount.find_or_create_by(email: "julia.fuchs3@openmailbox.org", password: 'Somename1', app_store: ru, kind: :flex)   #RU

      AppleAccount.all.each do |aa| 
        aa.in_use = false
        aa.save
      end

      apple_account_reserver = self.new
      apple_account_reserver.reserve(:one_off_intl, app_store_id: cn.id)
      apple_account_reserver.apple_account
    end

  end

end
