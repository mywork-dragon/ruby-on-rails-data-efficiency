module AppmonstaApi
  class Base

    include HTTParty

    BASE_URI = ENV['APPMONSTA_BASE_URI'].freeze
    BASIC_AUTH = {username: ENV['APPMONSTA_USER'], password: ''} #Currently doesn't use password

    base_uri BASE_URI

    def self.get_single_app_details(platform, app_identifier, country='ALL')
      case platform.to_s
      when 'android'
        request_single_app_details(:android, app_identifier, country)
      when 'ios'
        request_single_app_details(:itunes, app_identifier, country)
      else
        raise "Platform not provided or wrong"
      end
    end


    private

    def self.request_single_app_details(platform, app_identifier, country)
      raise "Platform not allowed: #{platform}" unless %i(android itunes).include?(platform)
      req = -> { get("/stores/#{platform}/details/#{app_identifier}.json?country=#{country}", basic_auth: BASIC_AUTH) }
      resp = send_request(req)
      raise_error_if_any!(resp.code)
      resp.parsed_response # Returns a Hash
    end
    
    def self.send_request(req)
      period = 1
      allowed_requests = 10
      throttler = Throttler.new("appmonsta_api_throttler", allowed_requests, period)
      throttler.increment
      req.call 
    rescue Throttler::LimitExceeded
      sleep(period/3)
      retry
    end

    def self.raise_error_if_any!(code)
      case code
      when 400 then raise RequestErrors::BadRequest
      when 401 then raise RequestErrors::Unauthorized
      when 403 then raise RequestErrors::NotAllowed
      when 404 then raise RequestErrors::NotFound
      when 429 then raise RequestErrors::RateLimitExceeded
      when 500 then raise RequestErrors::InternalServerErrror
      end
    end
  end
end
