class AutopilotApi
  include HTTParty

  API_KEY = ENV['API_AUTOPILOT_KEY'].to_s

  base_uri 'https://api2.autopilothq.com/v1/contact'

  def self.post_contact(email)
    # Adds or updates contact
    post(
      '/contact',
      headers: {
        'autopilotapikey' => API_KEY,
        'Content-Type' => 'application/json'
      },
      body: { "contact": { "Email": email } }
    )
  end
end
