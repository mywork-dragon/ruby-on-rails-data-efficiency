module Oauth
  class SalesforceUser < Oauth::Base

    def get_data
      response = @client.get(@parsed_response['id'], access_token: @access_token)
      @data = JSON.parse(response.body).with_indifferent_access
      @uid = @data[:user_id]
      @data
    end

    def self.access_token_url
      'https://login.salesforce.com/services/oauth2/token'
    end

    def formatted_user_data
      {
        provider:           'salesforceuser',
        token:              @access_token,
        salesforce_profile: @data['urls']['profile'],
        email:              @data['email'],
        image_url:          @data['photos']['picture'],
        first_name:         @data['first_name'],
        last_name:          @data['last_name'],
        uid:                @data['user_id']
      }
    end

  end
end