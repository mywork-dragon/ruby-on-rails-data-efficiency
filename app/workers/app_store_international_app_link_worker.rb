class AppStoreInternationalAppLinkWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: false, queue: :ios_international_scrape

  def perform
    num = IosAppCurrentSnapshotBackup.count
    puts "There are #{num} rows. This should take approximately #{num * 1.5 / 100_000}s"
    sql = 'insert into `app_stores_ios_app_backups` (ios_app_id, app_store_id, updated_at, created_at)
    select ios_app_id, app_store_id, updated_at, created_at  from `ios_app_current_snapshot_backups`;'
    ActiveRecord::Base.connection.execute(sql)
  end
end
