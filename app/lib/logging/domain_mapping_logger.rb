class DomainMappingLogger
  attr_reader :event

  def initialize(domain, ios_publisher_id, android_publisher_id, zendesk_id)
    @domain = domain
    @ios_publisher_id = ios_publisher_id
    @android_publisher_id = android_publisher_id
    @zendesk_id = zendesk_id
    @event = {}
  end

  def send!
    build_event
    RedshiftLogger.new(records: [@event], table: 'domain_mapping_zd').send!
  end

  def build_event
    set_info(:timestamp, DateTime.now.utc.iso8601)
    set_info(:ios_publisher_id, @ios_publisher_id)
    set_info(:android_publisher_id, @android_publisher_id)
    set_info(:domain, @domain)
    set_info(:zendesk_id, @zendesk_id)
  end

  def set_info(k, v)
    @event[k] = v
  end
end
