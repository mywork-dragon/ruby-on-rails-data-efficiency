module Oauth
  class Base
    attr_reader :provider, :data, :access_token, :uid

    def initialize params
      @provider = self.class.name.split('::').last.downcase
      prepare_params params
      puts "PROVIDER - #{@provider}"
      puts "PARAMS - #{@params}"
      @client = HTTPClient.new
      @access_token = params[:access_token].presence || get_access_token
      puts "ACCESS TOKEN IS - #{@access_token}"
      get_data if @access_token.present?
    end

    def get_access_token
      response = @client.post(self.class.access_token_url, @params)
      puts "ACCESS TOKEN RESPONSE - #{response.body}"
      parsed_response = JSON.parse(response.body)
      @parsed_response = parsed_response
      parsed_response["access_token"]
    end

    def prepare_params params
      @params = {
        code:          params[:code],
        redirect_uri:  params[:redirectUri],
        client_id:     self.client_id,
        client_secret: self.client_secret,
        grant_type:    'authorization_code'
      }
    end

    def client_id
      case @provider
      when 'linkedin'
        '755ulzsox4aboj'
      when 'google'
        '341121226980-egcfb2qebu8skkjq63i1cdfpvahrcuak.apps.googleusercontent.com'
      when 'salesforce', 'salesforceuser', 'salesforcesandbox', 'salesforceusersandbox'
        '3MVG9i1HRpGLXp.pUhSTB.tZbHDa3jGq5LTNGRML_QgvmjyWLmLUJVgg4Mgly3K_uil7kNxjFa0jOD54H3Ex9'
      end
    end

    def client_secret
      case @provider
      when 'linkedin'
        ENV['LINKEDIN_AUTH_CLIENT_SECRET'].to_s
      when 'google'
        ENV['GOOGLE_AUTH_CLIENT_SECRET'].to_s
      when 'salesforce', 'salesforceuser', 'salesforcesandbox', 'salesforceusersandbox'
        ENV['SALESFORCE_AUTH_CLIENT_SECRET'].to_s
      end
    end

    def authorized?
      @access_token.present?
    end
  end

end
