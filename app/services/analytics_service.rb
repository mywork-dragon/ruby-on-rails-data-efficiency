# For in-house analytics analysis
module AnalyticsService

  class CustomerSuccess

    class << self
      
      # Export for events
      def export_for_events(events:, how_long_ago:)
        fail HowLongAgoWrongClass unless how_long_ago.class == Date

        client = AnalyticsService::mixpanel_client

        data = client.request(
          'export',
          event:     events,
          from_date: how_long_ago,
          to_date:   Date.current
        )
      end

      class HowLongAgoWrongClass < StandardError
        def initialize(message = "how_long_ago must be a Date")
          super(message)
        end
      end

    end

  end
  
  class << self

    def mixpanel_client
      Mixpanel::Client.new(
        api_key: ENV['MIXPANEL_API_KEY'].to_s,
        api_secret: ENV['MIXPANEL_API_SECRET'].to_s
      )
    end

  end

end
