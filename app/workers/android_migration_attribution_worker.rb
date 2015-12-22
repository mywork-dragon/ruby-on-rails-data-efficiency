class AndroidMigrationAttributionWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :sdk

  def perform(android_sdk_id)
    sdk = AndroidSdk.find(android_sdk_id)
    correct_sdk_id = sdk.name.split(':').second
    AndroidSdksApkSnapshot.where(android_sdk_id: sdk.id).find_each do |row|
      row.update(android_sdk_id: correct_sdk_id)
    end
  end
end