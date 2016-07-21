class ItunesApi

  LOOKUP_ATTEMPTS = 2

  include HTTParty
  include ProxyParty

  base_uri 'https://itunes.apple.com'
  format :json

  class FailedRequest < RuntimeError; end
  class RateLimit < RuntimeError; end

  def self.lookup_app_info(app_identifier)
    proxy_request do

      data, attempts = nil, 0

      while data.nil? && attempts < LOOKUP_ATTEMPTS
        begin
          data = JSON.parse(get('/lookup', query: {id: app_identifier, uslimit: 1}).body)
        rescue => e
          puts "HTTParty Error"
          puts e.class
          puts e.backtrace
          nil
        end
      end

      raise FailedRequest, "Could not contact iTunes API, looking for app identifier #{app_identifier}" if data.nil?
      
      data

    end
  end

  # can only handle ~150 app identifiers at a time. To do more, call consecutively
  def self.batch_lookup(app_identifiers, country_code='us')
    proxy_request(proxy_type: :android_classification) do
      res = get('/lookup', query: {id: app_identifiers.join(','), country: country_code})
      raise RateLimit if res.code == 403
      JSON.parse(res.body)
    end
  end

end
