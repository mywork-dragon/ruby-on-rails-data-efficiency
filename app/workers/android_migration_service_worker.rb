class AndroidMigrationServiceWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :sdk

  METHOD = :move_snapshots

  def perform(id)
    if method == :move_snapshots
      move_snapshot(id)
    else
      fix_attribution(id)
    end
  end

  def move_snapshot(android_sdk_companies_apk_snapshot_id)
    row = AndroidSdkCompaniesApkSnapshot.find(android_sdk_companies_apk_snapshot_id)
    new_row = {
      id: row.id,
      android_sdk_id: row.android_sdk_company_id,
      apk_snapshot_id: row.apk_snapshot_id
    }
    AndroidSdksApkSnapshot.create!(new_row)
  end

  def fix_attribution(android_sdk_id)
    sdk = AndroidSdk.find(android_sdk_id)
  end
end