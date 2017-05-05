class ItunesTos

  include HTTParty
  include ProxyParty

  base_uri 'http://www.apple.com/legal/internet-services/itunes'
  format :html

  class InvalidHTML < RuntimeError; end
  class InvalidInput < RuntimeError; end

  def self.itunes_updated_date(app_store_id:)
    app_store = AppStore.find(app_store_id)
    raise InvalidInput unless app_store.tos_url_path.present? && app_store.tos_url_path.first == '/'

    proxy_request(proxy_type: :general) do
      res = get(app_store.tos_url_path)
      date_text = last_updated_text(res.body)
      validate_date_text(date_text)
      extract_date(date_text)
    end
  end

  def self.extract_date(date_text)
    date = date_text.split(':').last
    english = GoogleTranslateApi.translate(date)
    Date.parse(english)
  end

  def self.last_updated_text(html)
    noko = Nokogiri::HTML(html)
    noko.css('main.main div.section-content > div.row > p:last-child').text.strip
  end

  def self.validate_date_text(text)
    error_message = nil
    error_message = 'colon check' unless text.split(':').count == 2
    error_message = 'length check' unless text.length < 50

    raise InvalidHTML, error_message if error_message
  end
end
