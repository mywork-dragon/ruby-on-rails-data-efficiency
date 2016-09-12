class AppStoreInternationalDevelopersQueueWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :scraper_master, retry: false

  def perform(method, *args)
    send(method, *args)
  end

  def queue_missing_developer_identifiers

    batch_size = 10e3.to_i

    [IosAppCurrentSnapshotBackup, IosAppCurrentSnapshot].each do |table|
      query = table.select(:developer_app_store_identifier).distinct
        .joins("LEFT JOIN ios_developers on #{table.table_name}.developer_app_store_identifier = ios_developers.identifier")
        .where('ios_developers.id is NULL')

      puts "Found #{query.count} developers"
      developer_ids = query.pluck(:developer_app_store_identifier)

      developer_ids.each_slice(100) do |slice|
        args = slice.compact.map { |x| [:rows_by_developer_identifier, x] }
        SidekiqBatchQueueWorker.perform_async(
          AppStoreDevelopersWorker.to_s,
          args,
          bid
        )
      end
    end
  end
  
  def queue_apps_without_developers

    batch_size = 10e3.to_i

    IosApp.select(:id).distinct
      .joins(:ios_app_current_snapshot_backups)
      .where(ios_developer_id: nil)
      .find_in_batches(batch_size: batch_size)
      .with_index do |the_batch, index|

      li "App #{index*batch_size}"

      the_batch.each_slice(100) do |slice|
        args = slice.compact.map { |x| [:rows_by_ios_app_id, x] }
        SidekiqBatchQueueWorker.perform_async(
          AppStoreDevelopersWorker.to_s,
          args,
          bid
        )
      end

    end
  end
end
