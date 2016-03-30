class ItunesApi

  LOOKUP_ATTEMPTS = 2

  include HTTParty
  include ProxyBase

  base_uri 'https://itunes.apple.com'
  format :json

  def self.lookup_app_info(app_identifier)
    data, attempts = nil, 0

    while data.nil? && attempts < LOOKUP_ATTEMPTS
      begin
        data = get('/lookup', query: {id: app_identifier, uslimit: 1})
      rescue => e
        puts "HTTParty Error"
        puts e.class
        puts e.backtrace
        nil
      end
    end

    data
  end

end
