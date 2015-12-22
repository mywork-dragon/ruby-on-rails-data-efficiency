class AndroidMigrationServiceWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :sdk

  def perform(android_sdk_companies_apk_snapshot_id)
    row = AndroidSdkCompaniesApkSnapshot.find(android_sdk_companies_apk_snapshot_id)
    new_row = {
      id: row.id,
      android_sdk_id: row.android_sdk_company_id,
      apk_snapshot_id: row.apk_snapshot_id
    }
    AndroidSdksApkSnapshot.create!(new_row)
  end
end