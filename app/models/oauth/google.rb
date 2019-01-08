module Oauth
  class Google < Oauth::Base
    # https://accounts.google.com/.well-known/openid-configuration
    USER_INFO_ENDPOINT = 'https://openidconnect.googleapis.com/v1/userinfo'

    def get_names
      names = data[:name].try(:split).to_a
      [data[:given_name] || names.first, data[:family_name] || names.last]
    end

    def self.access_token_url
      # Obtain the value for access_token_url from:
      # https://accounts.google.com/.well-known/openid-configuration
      'https://oauth2.googleapis.com/token'
    end

    def get_data
      response = @client.get(USER_INFO_ENDPOINT, access_token: @access_token)
      @data = JSON.parse(response.body).with_indifferent_access
      @uid = @data[:id] ||= @data[:sub]
      @data
    end

    def formatted_user_data
      {
        provider:       'google',
        token:          @access_token,
        uid:            @data['id'],
        first_name:     @data['given_name'],
        last_name:      @data['family_name'],
        email:          @data['email'],
        image_url:      @data['picture'].gsub("?sz=50", ""),
        google_profile: @data['profile']
      }
    end

  end
end
