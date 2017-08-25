module Oauth
  class Salesforce < Oauth::Base

    def self.access_token_url
      'https://login.salesforce.com/services/oauth2/token'
    end

    def get_data
      response = @client.get(@parsed_response['id'], access_token: @access_token)
      @data = JSON.parse(response.body).with_indifferent_access
      @uid = @data[:user_id]
      @data
    end

    def formatted_user_data
      {
        provider:           'salesforce',
        token:              @access_token,
        refresh_token:      @parsed_response['refresh_token'],
        instance_url:       @parsed_response['instance_url'],
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