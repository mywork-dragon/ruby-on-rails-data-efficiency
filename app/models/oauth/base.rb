module Oauth
  class Base
    attr_reader :provider, :data, :access_token, :uid

    def initialize params
      @provider = self.class.name.split('::').last.downcase
      prepare_params params
      puts "PARAMS - #{@params}"
      @client = HTTPClient.new
      @access_token = params[:access_token].presence || get_access_token
      puts "ACCESS TOKEN IS - #{@access_token}"
      get_data if @access_token.present?
    end

    def get_access_token
      response = @client.post(self.class::ACCESS_TOKEN_URL, @params)
      puts "ACCESS TOKEN RESPONSE - #{response.body}"
      JSON.parse(response.body)["access_token"]
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
      if @provider == 'linkedin'
        '755ulzsox4aboj'
      else
        '341121226980-egcfb2qebu8skkjq63i1cdfpvahrcuak.apps.googleusercontent.com'
      end
    end

    def client_secret
      if @provider == 'linkedin'
        'eidrZL6asyWvONuh'
      else
        'alyqEz-2j7Edf1_fUQpC3K1j'
      end
    end

    def authorized?
      @access_token.present?
    end
  end

end