class AppStoreInternationalDevelopersQueueWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :scraper_master, retry: false

  def perform

    batch_size = 10e3.to_i
    query = IosAppCurrentSnapshotBackup.select(:developer_app_store_identifier).distinct
      .joins('LEFT JOIN ios_developers on ios_app_current_snapshot_backups.developer_app_store_identifier = ios_developers.identifier')
      .where('ios_developers.id is NULL')

    puts "Found #{query.count} developers"
    developer_ids = query.pluck(:developer_app_store_identifier)

    developer_ids.each_slice(100) do |slice|
      args = slice.compact.map { |x| [x] }
      SidekiqBatchQueueWorker.perform_async(
        AppStoreDevelopersWorker.to_s,
        args,
        bid
      )
    end
  end
end
