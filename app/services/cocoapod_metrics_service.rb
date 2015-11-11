class CocoapodMetricsService

  class << self

    # get all the cocoapods
    pod_sdks = IosSdk.find(Cocoapod.select(:ios_sdk_id).map{|x| x.ios_sdk_id}.compact.uniq)
    # filter deprecated?
    
    pod_sdks.each do |sdk|
      if Rails.env.production?
        CocoapodMetricsServiceWorker.perform(sdk.id)
      else
        CocoapodMetricsServiceWorker.new.perform(sdk.id)
      end
    end
  end
end