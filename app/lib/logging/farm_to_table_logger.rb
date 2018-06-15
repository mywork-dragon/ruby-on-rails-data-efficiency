class FarmToTableLogger
  attr_reader :event

  def initialize(android_app, email)
    @android_app = android_app
    @android_developer = android_app.android_developer
    @email = email
    @event = {}
  end

  def send!
    build_event
    RedshiftLogger.new(records: [@event], table: 'android_emails').send!
  end

  def build_event
    set_info(:timestamp, DateTime.now.utc.iso8601)
    set_info(:android_app_id, @android_app.id)
    set_info(:android_developer_id, @android_developer.try(:id))
    set_info(:email, @email)
  end

  def set_info(k, v)
    @event[k] = v
  end
end
