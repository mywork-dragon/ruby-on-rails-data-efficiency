class AmplitudeApi
  include HTTParty

  API_KEY = ENV['API_AMPLITUDE_KEY'].to_s

  base_uri 'https://api.amplitude.com'

  def self.track(event_data)
    post(
      '/httpapi',
      body: {
        api_key: API_KEY,
        event: [event_data].to_json
      }
    )
  end
end
