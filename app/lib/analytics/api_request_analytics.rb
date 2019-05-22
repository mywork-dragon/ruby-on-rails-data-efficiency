# Used in ClientApi::AndroidAppController and many other places

class ApiRequestAnalytics

  attr_accessor :event_data, :api_token, :request
  attr_writer :throttler

  def initialize(request, api_token)
    @request = request
    @api_token = api_token
    @event_data = {
      event_properties: {}
    }
  end

  def throttler
    @throttler ||= Throttler.new(@api_token.token, @api_token.rate_limit, @api_token.period)
  end

  def log_request(name)
    build_event_data
    add_property(:event_type, name)
    ApiRequestAnalyticsWorker.perform_async(@event_data)
  end

  def build_event_data
    add_user_data
    add_request_data
  end

  def add_user_data
    add_property(:user_id, @api_token.account.name)
    add_event_property(:token_id, @api_token.id)
  end

  def add_request_data
    add_event_property(:request_id, @request.uuid)
    add_event_property(:url, @request.original_url)
    add_event_property(:method, @request.request_method)
    add_event_property(
      :window_request_count,
      throttler.status[:current]
    )
    store_object_to_event_properties('param', @request.query_parameters)
  end

  def store_object_to_event_properties(prefix, source)
    source.keys.map do |key|
      add_event_property("#{prefix}_#{key}", source[key])
    end
  end

  def add_event_property(key, value)
    @event_data[:event_properties][key] = value
  end

  def add_property(key, value)
    @event_data[key] = value
  end
end
