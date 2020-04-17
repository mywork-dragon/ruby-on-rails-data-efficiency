#
# This hotstore importer don't implement a limit of relevant sdks since
# the amount of total SDKs is small.
#

class SdkHotStoreImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :hot_store_application_import, retry: 2

  def perform(platform, sdk_id)
    @hs ||= SdkHotStore.new
    @hs.write(platform, sdk_id)
  end

  def queue_ios_sdks
    IosSdk.pluck(:id).map do |id|
      SdkHotStoreImportWorker.perform_async("ios", id)
    end
  end

  def queue_android_sdks
    AndroidSdk.pluck(:id).map do |id|
      SdkHotStoreImportWorker.perform_async("android", id)
    end
  end

  def queue_sdks
    queue_ios_sdks
    queue_android_sdks
  end

end
