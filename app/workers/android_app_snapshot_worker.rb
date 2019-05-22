# class AndroidAppSnapshotWorker
#   include Sidekiq::Worker
#
#   # limit to 50 concurrency
#   sidekiq_options queue: :default, retry: false
#
#   def perform(method, *args)
#     send(method, *args)
#   end
#
#   def start_snapshot_migration
#     batch = Sidekiq::Batch.new
#     batch.description = 'Migrating android app snapshots to a backup table'
#     batch.on(:complete, 'AndroidAppSnapshotWorker#on_complete')
#
#     batch.jobs do
#       AndroidAppSnapshotWorker.perform_async(:queue_android_apps, :copy_android_app_snapshots)
#     end
#   end
#
#   def start_snapshot_repointing
#     batch = Sidekiq::Batch.new
#     batch.description = 'Migrating android app snapshots to a backup table'
#     batch.on(:complete, 'AndroidAppSnapshotWorker#on_complete')
#
#     batch.jobs do
#       AndroidAppSnapshotWorker.perform_async(:queue_android_apps, :move_android_app_snapshot_pointer)
#     end
#   end
#
#   # TODO: write the repointer worker
#   def move_android_app_snapshot_pointer(android_app_ids)
#     android_app_ids.each do |android_app_id|
#       app = AndroidApp.find(android_app_id)
#       new_snapshot = AndroidAppSnapshot.find_by_android_app_id(android_app_id)
#       next unless new_snapshot
#       app.update!(newest_android_app_snapshot_id: new_snapshot.id)
#     end
#   end
#
#   def queue_android_apps(method)
#     AndroidApp.select(:id).where.not(newest_android_app_snapshot_id: nil)
#       .find_in_batches(batch_size: 1_000)
#       .with_index do |the_batch, index|
#
#       li "App #{index * 1_000}"
#
#       args = the_batch.each_slice(200).map do |slice|
#         [method, slice.map(&:id).compact]
#       end
#
#       SidekiqBatchQueueWorker.perform_async(
#         AndroidAppSnapshotWorker.to_s,
#         args,
#         bid
#       )
#     end
#   end
#
#   def copy_android_app_snapshots(android_app_ids)
#     rows = android_app_ids.map do |android_app_id|
#       previous = AndroidApp.find(android_app_id).newest_android_app_snapshot
#       convert_previous_to_current(previous) if previous
#     end.compact
#
#     AndroidAppSnapshotBackup.import rows
#   end
#
#   def convert_previous_to_current(previous)
#     new_row = AndroidAppSnapshotBackup.new
#     AndroidAppSnapshot.column_names.each do |column|
#       next if ['id', 'created_at', 'updated_at'].include?(column)
#       new_row[column.to_sym] = previous[column.to_sym]
#     end
#     new_row
#   end
#
#   def swap_tables
#     print 'About to swap tables. Are you sure you want to continue? [y/n]: '
#     return unless gets.chomp.include?('y')
#
#     query = table_swap_map.keys.map do |prod_table|
#       prod_table_name = prod_table.table_name
#       backup_table_name = table_swap_map[prod_table].table_name
#       tmp_table_name = "tmp_#{prod_table_name}"
#       [
#         source_dest_syntax(backup_table_name, tmp_table_name),
#         source_dest_syntax(prod_table_name, backup_table_name),
#         source_dest_syntax(tmp_table_name, prod_table_name)
#       ]
#     end.flatten.join(",\n")
#     puts
#     puts query = "RENAME TABLE #{query};"
#
#     print 'Does the following query look ok? [y/n] : '
#     return unless gets.chomp.include?('y')
#     ActiveRecord::Base.connection.execute(query)
#   end
#
#   def table_swap_map
#     {
#       AndroidAppSnapshot => AndroidAppSnapshotBackup
#     }
#   end
#
#   def source_dest_syntax(source_table, dest_table)
#     "#{source_table} to #{dest_table}"
#   end
#
#   def on_complete(status, options)
#     Slackiq.notify(webhook_name: :main, status: status, title: 'Migrated newest android app snapshots')
#   end
# end
