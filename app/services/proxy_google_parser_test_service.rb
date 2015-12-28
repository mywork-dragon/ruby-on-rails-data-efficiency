# To test Proxy with GoogleParser
class ProxyGoogleParserTestService

  class << self

    def run
      self.new.run
    end

  end

  def run
    sdks = %w(
      baidu
      localytics
      mixpanel
      lfasnlksnflkansflkanslkfnlasknca
      apsalar
      tune
      )

    # sdks = %w(
    #     optimizely
    #     parse
    #     marketo
    #     cmcmcmmcmcmalsalsamflkamslkm
    #     )

    results = sdks.each do |sdk|
      html_s = Proxy.get_body(req: {:host => "www.google.com/search", :protocol => "https"}, params: {'q' => "#{sdk} ios sdk"})
      ap GoogleParser::Parser.parse(html_s)
      sleep(rand(1.0..2.0)) # be nice to google
    end

    true

  end

end