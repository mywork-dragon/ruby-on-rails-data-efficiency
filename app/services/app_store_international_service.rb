class AppStoreInternationalService

  class << self

    def run_snapshots(automated: false, scrape_all: false)
      batch = Sidekiq::Batch.new
      batch.description = "AppStoreInternationalService.run_snapshots" 
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_snapshots',
        'automated' => automated
      )

      batch.jobs do
        AppStoreInternationalSnapshotQueueWorker.perform_async(scrape_all)
      end
    end

    def run_scaling_factors(automated: false)
      batch = Sidekiq::Batch.new
      batch.description = "AppStoreInternationalService#run_scaling_factors" 
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_scaling_factors',
        'automated' => automated
      )

      Slackiq.message("Starting to calculate scaling factors", webhook_name: :main)

      batch.jobs do
        AppStore.where(enabled: true).each do |app_store|
          AppStoreInternationalScalingFactorsWorker.perform_async(app_store.id)
        end
      end
    end

    def run_user_bases(automated: false)
      batch = Sidekiq::Batch.new
      batch.description = 'AppStoreInternationalService#run_user_bases'
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_user_bases',
        'automated' => automated
      )

      Slackiq.message("Starting to populate user bases", webhook_name: :main)

      batch.jobs do
        AppStore.where(enabled: true).each do |app_store|
          AppStoreInternationalUserBaseWorker.perform_async(app_store.id)
        end
      end
    end

    def run_app_store_linking(automated: false)
      batch = Sidekiq::Batch.new
      batch.description = 'AppStoreInternationalService#run_app_store_linking'
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_app_store_linking',
        'automated' => automated
      )

      Slackiq.message("Starting to link app stores to apps", webhook_name: :main)

      batch.jobs do
        AppStoreInternationalAppLinkWorker.perform_async
      end
    end

    def run_developers(automated: false)
      batch = Sidekiq::Batch.new
      batch.description = 'AppStoreInternationalService#run_developers'
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_run_developers',
        'automated' => automated
      )

      Slackiq.message("Starting to create developers", webhook_name: :main)

      batch.jobs do
        AppStoreInternationalDevelopersQueueWorker.perform_async
      end
    end

    def app_store_availability(new_store_updates: false)
      batch = Sidekiq::Batch.new
      batch.description = 'AppStoreInternationalService#app_store_availability'
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_app_store_availability'
      )

      Slackiq.message('Starting to update app store availability', webhook_name: :main)

      batch.jobs do
        AppStoreInternationalAvailabilityWorker.perform_async(new_store_updates)
      end
    end

    # table pairings to be swapped. convention is production table --> backup table
    def table_swap_map
      {
        IosAppCurrentSnapshot => IosAppCurrentSnapshotBackup,
        IosAppCategoryName => IosAppCategoryNameBackup,
        IosAppCategoriesCurrentSnapshot => IosAppCategoriesCurrentSnapshotBackup,
        AppStoresIosApp => AppStoresIosAppBackup,
        AppStoreScalingFactor => AppStoreScalingFactorBackup
      }
    end

    def test_table_swap
      ActiveRecord::Base.logger.level = 1
      rev_map = table_swap_map.invert
      correct = {}

      ap "BEFORE"
      table_swap_map.keys.each do |table|
        puts "#{table.to_s}: #{table.count}"
        correct[table] = table.count
      end
      rev_map.keys.each do |table|
        puts "#{table.to_s}: #{table.count}"
        correct[table] = table.count
      end

      swap_tables

      ap "AFTER"
      table_swap_map.keys.each do |table|
        puts "#{table.to_s}: #{table.count}"
      end
      rev_map.keys.each do |table|
        puts "#{table.to_s}: #{table.count}"
      end

      ap "VALIDATING"
      correct.keys.each do |table|
        expecting = if table_swap_map.key?(table)
                      correct[table_swap_map[table]]
                    else
                      correct[rev_map[table]]
                    end
        raise "FAILED FOR TABLE #{table.to_s}. expected #{expecting}. Received #{table.count}" unless expecting == table.count
      end

      ap "SUCCESS"
    end

    def swap_tables
      print 'About to swap tables. Are you sure you want to continue? [y/n]: '
      return unless gets.chomp.include?('y')

      query = table_swap_map.keys.map do |prod_table|
        prod_table_name = prod_table.table_name
        backup_table_name = table_swap_map[prod_table].table_name
        tmp_table_name = "tmp_#{prod_table_name}"
        [
          source_dest_syntax(backup_table_name, tmp_table_name),
          source_dest_syntax(prod_table_name, backup_table_name),
          source_dest_syntax(tmp_table_name, prod_table_name)
        ]
      end.flatten.join(",\n")
      puts
      puts query = "RENAME TABLE #{query};"

      print 'Does the following query look ok? [y/n] : '
      return unless gets.chomp.include?('y')
      ActiveRecord::Base.connection.execute(query)
    end

    def source_dest_syntax(source_table, dest_table)
      "#{source_table} to #{dest_table}"
    end

    def clear_backup_tables
      [
        IosAppCategoryNameBackup,
        IosAppCurrentSnapshotBackup,
        IosAppCategoriesCurrentSnapshotBackup,
        AppStoresIosAppBackup,
        AppStoreScalingFactorBackup
      ].each {|x| reset_table(x) }
    end

    def reset_table(model_name)
      puts "Resetting #{model_name.to_s}: #{model_name.count} rows"
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{model_name.table_name}")
    end
  end

  def on_complete_snapshots(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Entire App Store Scrape (international) completed')

    if options['automated']
      self.class.run_scaling_factors(automated: true)
    end
  end

  def on_complete_scaling_factors(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Calculated scaling factors for app stores')

    if options['automated']
      self.class.run_user_bases(automated: true)
    end
  end

  def on_complete_user_bases(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Populated user bases')

    if options['automated']
      self.class.run_app_store_linking(automated: true)
    end
  end

  def on_complete_app_store_linking(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Populated app links')

    if options['automated']
      self.class.run_developers(automated: true)
    end
  end

  def on_complete_run_developers(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Created missing developers')
  end

  def on_complete_app_store_availability(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Updated iOS app store availabilities')
  end

end
