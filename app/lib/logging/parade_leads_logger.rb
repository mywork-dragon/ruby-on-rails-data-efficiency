class ParadeLeadsLogger
  attr_reader :event

  def initialize(first_name, last_name, email, title)
    @first_name = first_name
    @last_name = last_name
    @email = email
    @title = title
    @event = {}
  end

  def send!
    build_event
    RedshiftLogger.new(records: [@event], table: 'parade_leads').send!
  end

  def build_event
    set_info(:timestamp, DateTime.now.utc.iso8601)
    set_info(:first_name, @first_name)
    set_info(:last_name, @last_name)
    set_info(:title, @title)
    set_info(:email, @email)
  end

  def set_info(k, v)
    @event[k] = v
  end
end
