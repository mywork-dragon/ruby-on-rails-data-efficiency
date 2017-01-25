class MightyApi

  API_TOKEN = ENV['MIGHTYSIGNAL_API_TOKEN'].to_s

  include HTTParty

  base_uri 'https://api.mightysignal.com'

  class FailedRequest < RuntimeError; end

  def self.ios_sdk_info(id)
    res = get(
      "/ios/sdk/#{id}",
      headers: header_credential
    )
    validate!(res)
    JSON.parse(res.body)
  end

  def self.validate!(res)
    raise FailedRequest, "#{res.code}: #{res.body}" unless res.code == 200
  end

  def self.header_credential
    { 'MIGHTYSIGNAL-TOKEN' => API_TOKEN }
  end

end

