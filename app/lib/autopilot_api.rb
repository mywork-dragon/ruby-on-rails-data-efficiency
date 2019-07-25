class AutopilotApi
  include HTTParty
  debug_output $stdout

  API_KEY = ENV['API_AUTOPILOT_KEY'].freeze

  base_uri ENV['API_AUTOPILOT_URI'].freeze

  def self.post_contact(email)
    # Adds or updates contact
    post(
      '/contact',
      headers: {
        'autopilotapikey' => API_KEY,
        'Content-Type' => 'application/json'
      },
      body: { "contact": { "Email": email } }.to_json
    )
  end
end
