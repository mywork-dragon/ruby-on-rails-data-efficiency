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
        api_key:    '6a96c6c2b8cb2ad6de06ad54957b2f2a',
        api_secret: 'f7d1ee068ddf3d2366d0ed89fe0618dc'
      )
    end

  end

end
