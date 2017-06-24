class ApiRequestAnalyticsWorker

  include Sidekiq::Worker

  sidekiq_options retry: 5, queue: :api_processing

  def perform(event_data)
    AmplitudeApi.track(event_data)
    notify_slack(event_data) if first_request?(event_data)
  end

  def first_request?(event_data)
    event_data['event_properties']['window_request_count'].to_i == 1
  end

  def notify_slack(event_data)
    HTTParty.post(
      'https://hooks.slack.com/services/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',
      body: {
        text: "#{event_data['user_id']} started using the API!"
      }.to_json,
      headers: {'Content-type' => 'application/json'})
  end
end
