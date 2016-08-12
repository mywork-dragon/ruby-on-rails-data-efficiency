class IosClassificationServiceWorker

  include Sidekiq::Worker

  include IosClassification

  sidekiq_options backtrace: true, retry: false, queue: :ios_live_scan_cloud

  class << self

    def test
      new.sdks_from_classnames_v2(classes: ['mixpanel', 'one', 'vcxsdf', 'mixpanel-ios-sdk', 'Titanium', 'BTUICardCvvField'])
    end

  end

end
