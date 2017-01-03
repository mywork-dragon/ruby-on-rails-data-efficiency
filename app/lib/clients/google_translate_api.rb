class GoogleTranslateApi

  API_KEY = ENV['GOOGLE_TRANSLATE_API_KEY'].to_s

  include HTTParty
  include ProxyParty

  base_uri 'https://translation.googleapis.com/language/translate/v2'
  format :json

  class FailedRequest < RuntimeError; end

  def self.translate(query, target: 'en')
    res = translate_raw(query, target: target)
    res['data']['translations'].first['translatedText']
  end

  def self.translate_raw(query, target: 'en')
    res = get('/', query: { key: API_KEY, target: target, q: query })
    validate!(res)
    JSON.parse(res.body)
  end

  def self.validate!(res)
    raise FailedRequest, res if res.code != 200
  end
end
