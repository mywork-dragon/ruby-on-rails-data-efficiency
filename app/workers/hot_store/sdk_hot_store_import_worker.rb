#
# This hotstore importer don't implement a limit of relevant sdks since
# the amount of total SDKs is small.
#

class SdkHotStoreImportWorker
  include Sidekiq::Worker
  include Utils::Workers
  sidekiq_options queue: :hot_store_application_import, retry: 2

  attr_reader :hs

  def initialize
    @hs = SdkHotStore.new
  end

  def perform(platform, sdk_id)
    hs.write(platform, sdk_id)
  end

  def queue_ios_sdks
    IosSdk.pluck(:id).map do |id|
      delegate_perform(self.class, IosApp::PLATFORM_NAME, id)
    end
  end

  def queue_android_sdks
    AndroidSdk.pluck(:id).map do |id|
      delegate_perform(self.class, AndroidApp::PLATFORM_NAME, id)
    end
  end

  def queue_sdks
    queue_ios_sdks
    queue_android_sdks
  end

end
