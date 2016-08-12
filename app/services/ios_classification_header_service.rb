class IosClassificationHeaderService
  class << self

    def populate_backup_table
      batch = Sidekiq::Batch.new
      batch.description = 'IosClassificationHeaderService#populate_backup_table'
      batch.on(:complete, 'IosClassificationHeaderService#on_complete_populate_backups')

      batch.jobs do
        IosClassificationHeaderWorker.perform_async(:queue_headers)
      end
    end

    def clear_backup_table
      model = IosClassificationHeadersBackup
      puts "Resetting #{model.to_s}: #{model.count} rows"
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{model.table_name}")
    end

    def swap_tables
      ActiveRecord::Base.logger.level = 1
      ap "BEFORE"
      print_counts

      tmp_table_name = 'tmp_ios_headers'
      prod_table_name = IosClassificationHeader.table_name
      backup_table_name = IosClassificationHeadersBackup.table_name
      query = "RENAME TABLE #{[
        source_dest_syntax(backup_table_name, tmp_table_name),
        source_dest_syntax(prod_table_name, backup_table_name),
        source_dest_syntax(tmp_table_name, prod_table_name)
      ].join(",\n")}"
      puts query

      print 'Does the following query look ok? [y/n] : '
      return unless gets.chomp.include?('y')
      ActiveRecord::Base.connection.execute(query)

      ap "AFTER"
      print_counts
    end

    def source_dest_syntax(source_table, dest_table)
      "#{source_table} to #{dest_table}"
    end

    def print_counts
      [IosClassificationHeader, IosClassificationHeadersBackup].each do |model|
        puts "#{model.to_s}: #{model.count}"
      end
    end
  end

  def on_complete_populate_backups(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Populated Backup Table')
  end
end