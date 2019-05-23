module Oauth
  class Linkedin < Oauth::Base
    DATA_URL = 'https://api.linkedin.com/v2/me'

    def get_data
      response = @client.get(DATA_URL, oauth2_access_token: @access_token)
      @data = JSON.parse(response.body).with_indifferent_access
      @uid = @data[:id] ||= @data[:sub]
      @data
    end

    def self.access_token_url
      'https://www.linkedin.com/oauth/v2/accessToken'
    end

    def formatted_user_data
      {
        provider:        'linkedin',
        token:            @access_token,
        linkedin_profile: @data['publicProfileUrl'],
        email:            @data['emailAddress'],
        image_url:        @data['pictureUrl'],
        first_name:       @data['firstName'],
        last_name:        @data['lastName'],
        about:            @data['summary'],
        uid:              @data['id']
      }
    end

  end
end