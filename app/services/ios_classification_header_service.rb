# Used in DAG

class IosClassificationHeaderService
  class << self

    def populate_backup_table
      clear_backup_table
      IosClassificationHeaderWorker.perform_async(:queue_headers)
    end

    def clear_backup_table
      model = IosClassificationHeadersBackup
      puts "Resetting #{model.to_s}: #{model.count} rows"
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{model.table_name}")
    end

    def swap_tables(automated: true, validate: true)
      validate_tables if validate
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

      unless automated
        print 'Does the following query look ok? [y/n] : '
        return unless gets.chomp.include?('y')
      end

      ActiveRecord::Base.connection.execute(query)

      ap "AFTER"
      print_counts
    end

    def validate_tables
      raise RuntimeError, 'Table is not above min size'  unless IosClassificationHeadersBackup.count >= 30_000
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
end
