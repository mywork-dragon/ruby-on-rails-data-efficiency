class SalesforceLogger
  attr_reader :event

  def initialize(event_name, account, publisher, model_name, new_record)
    @account = account # mightsignal account of export
    @event_name = event_name 
    @publisher = publisher # ios or android publisher getting exported
    @model_name = model_name # exporting into lead or account?
    @new_record = new_record # enriching existing salesforce object or creating new salesforce record?
    @event = {}
  end

  def send!
    build_event
    RedshiftLogger.new(records: [@event], table: 'salesforce_metrics').send!
  end

  def build_event
    set_info(:timestamp, DateTime.now.utc.iso8601)
    set_info(:event_name, @event_name)
    set_info(:account_id, @account.id)
    set_info(:account_name, @account.name)
    set_info(:export_model, @model_name)
    set_info(:new_record, @new_record)
    set_info(:publisher_id, @publisher.id)
    set_info(:publisher_name, @publisher.name)
    set_info(:publisher_platform, @publisher.platform)
  end

  def set_info(k, v)
    @event[k] = v
  end
end
