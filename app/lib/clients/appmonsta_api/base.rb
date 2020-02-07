module AppmonstaApi
  class Base

    include HTTParty

    BASE_URI = ENV['APPMONSTA_BASE_URI'].freeze
    PORT = ENV['APPMONSTA_BASE_PORT'] || 80
    BASIC_AUTH = {username: ENV['APPMONSTA_USER'], password: ''} #Currently doesn't use password

    base_uri BASE_URI

    def self.get_single_app_attributes(platform, app_identifier, country='ALL')
      case platform.to_s
      when 'android'
        response = get_single_app_details(:android, app_identifier, country)
        AppmonstaAndroidSingleResponse.new(response.parsed_response)
      when 'ios'
        response = get_single_app_details(:itunes, app_identifier, country)
        AppmonstaIosSingleResponse.new(response.parsed_response)
      else
        raise StandardError.new("Platform not provided or wrong")
      end
    end


    private

    def self.get_single_app_details(platform, app_identifier, country)
      raise StandardError.new("Platform not allowed: #{platform}") unless %i(android itunes).include?(platform)
      get("/stores/#{platform}/details/#{app_identifier}.json?country=#{country}", basic_auth: BASIC_AUTH)
    end
  end
end
