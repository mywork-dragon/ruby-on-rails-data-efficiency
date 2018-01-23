# modeled after IosDeviceReserver
class GoogleAccountReserver
  DEFAULT_WAIT_TIME = 60 * 60 * 24 * 365 # 1 year
  DEFAULT_SLEEP_RANGE = (1...4)
  SCRAPE_TYPES = {
    live: :immediate_reserve,
    full: :patient_reserve
  }

  attr_reader :owner, :account

  def initialize(owner = nil, max_wait: nil)
    @account = nil
    @owner = owner
    @max_wait = max_wait || DEFAULT_WAIT_TIME
  end

  def reserve(scrape_type, requirements = {})
    raise MultipleReservation if @account
    raise UnregisteredReserveType, scrape_type unless GoogleAccount.scrape_types[scrape_type] && SCRAPE_TYPES[scrape_type]
    send(SCRAPE_TYPES[scrape_type], scrape_type, requirements)
  end

  def immediate_reserve(scrape_type, requirements)
    any_exist?(scrape_type, requirements)

    account = try_reserve(scrape_type, requirements)

    raise UnavailableAccount if account.nil?

    @account = account
  end

  def patient_reserve(scrape_type, requirements)
    account = nil
    start_time = Time.now

    while account.nil? && Time.now - start_time < @max_wait
      any_exist?(scrape_type, requirements)
      puts "sleeping"
      sleep(Random.new.rand(DEFAULT_SLEEP_RANGE))
      account = try_reserve(scrape_type, requirements)
    end

    raise UnavailableAccount if account.nil?
    @account = account
  end

  def release
    raise NoAccountReserved if @account.nil?

    @account.in_use = false
    @account.save

    @account = nil
  end

  def has_account?
    @account.present?
  end

  # private UNCOMMENT ME
  def any_exist?(scrape_type, requirements)
    query = build_query(scrape_type, requirements, available_only: false)
    raise NoSuchAccount unless query.take.present?
  end

  def build_query(scrape_type, requirements, available_only: true)
    query_parts = []

    query_parts << "id = #{requirements[:google_account_id]}" if requirements[:google_account_id]
    query_parts << "scrape_type = #{GoogleAccount.scrape_types[scrape_type]}"

    if available_only
      query_parts << 'in_use = false'
    end

    if requirements[:forbidden_google_account_ids].present? # array also non-empty
      query_parts << "id not in (#{requirements[:forbidden_google_account_ids].join(', ')})"
    end

    query_parts << "blocked = false"

    where_clause = query_parts.join(' and ')

    query = GoogleAccount.where(where_clause)

    if requirements[:excluded_devices].present?
      query = query.where.not(device: requirements[:excluded_devices])
    end

    query
  end

  def try_reserve(scrape_type, requirements)
    query = build_query(scrape_type, requirements, available_only: false)
    g = query.order(device: :desc, last_used: :asc).limit(1).take

    if g
      g.last_used = DateTime.now
      g.save
    end
    g
  end

  # Errors
  class MultipleReservation < RuntimeError; end
  class UnregisteredReserveType < RuntimeError; end
  class NoAccountReserved < RuntimeError; end
  class UnavailableAccount < RuntimeError; end
  class NoSuchAccount < RuntimeError; end
end
