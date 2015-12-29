# To test Proxy with GoogleSearcher
class ProxyGoogleSearcherTestService

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
      ap GoogleSearcher::Searcher.search("#{sdk} ios sdk", proxy_type: :android_classification)
      sleep(rand(1.0..2.0)) # be nice to google
    end

    true

  end

end