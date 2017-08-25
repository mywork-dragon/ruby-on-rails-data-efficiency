module Oauth
  class SalesforceSandbox < Oauth::Salesforce

    def self.access_token_url
      'https://test.salesforce.com/services/oauth2/token'
    end

    def formatted_user_data
      super.merge(is_sandbox: true)
    end
  end
end