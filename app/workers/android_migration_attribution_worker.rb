class AndroidMigrationAttributionWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :sdk

  def perform(android_sdk_id)
    sdk = AndroidSdk.find(android_sdk_id)
    correct_sdk_id = sdk.name.split(':').second
    AndroidSdksApkSnapshot.where(android_sdk_id: sdk.id).find_each do |row|
      exists = AndroidSdksApkSnapshot.where(apk_snapshot_id: row.apk_snapshot_id, android_sdk_id: correct_sdk_id).take

      if exists.nil?
        row.update(android_sdk_id: correct_sdk_id) 
      else
        row.delete
      end
    end
  end
end