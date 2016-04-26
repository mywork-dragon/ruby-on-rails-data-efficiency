class WtfIsMyIp

  include HTTParty

  base_uri 'https://wtfismyip.com'
  format :json

  class InvalidResponse < RuntimeError; end

  def self.connection_info

    raw = get('/json')
    
    resp = {
      ip: raw["YourFuckingIPAddress"].strip,
      location: raw["YourFuckingLocation"].strip,
      hostname: raw["YourFuckingHostname"].strip,
      isp: raw["YourFuckingISP"].strip,
      tor_exit: raw["YourFuckingTorExit"].strip
    }

    raise InvalidResponse if resp.values.any?(&:nil?)

    resp

  end

end
