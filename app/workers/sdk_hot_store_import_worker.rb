class SdkHotStoreImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :hot_store_application_import, retry: 2

  def initialize
    @hot_store = SdkHotStore.new
  end

  def perform(platform, sdk_id)
    @hot_store.write(platform, sdk_id)
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
