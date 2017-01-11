class AppStoreInternationalService

  class UnrecognizedType < RuntimeError; end

  class << self

    def run_snapshots(automated: false, scrape_type: :regular)
      batch = Sidekiq::Batch.new
      batch.description = "AppStoreInternationalService.run_snapshots" 
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_snapshots',
        'automated' => automated
      )

      Slackiq.message('Starting to queue iOS international apps', webhook_name: :main)
      notes = "Full scrape (international) #{Time.now.strftime("%m/%d/%Y")}"
      j = IosAppCurrentSnapshotJob.create!(notes: notes)

      query = snapshot_query_by_scrape_type(scrape_type)
      snapshot_worker = snapshot_worker_by_scrape_type(scrape_type)

      enabled_app_store_ids = AppStore.where(enabled: true).pluck(:id)

      ids = IosApp.where(query).pluck(:id)
      batch.jobs do
        # limit at 150 so http requests to iTunes API do not fail
        ids.each_slice(150) do |slice|
          args = enabled_app_store_ids.map do |app_store_id|
            [j.id, slice, app_store_id]
          end

          SidekiqBatchQueueWorker.perform_async(
            snapshot_worker.to_s,
            args,
            batch.bid
          )
        end
      end

      Slackiq.message("Done queueing App Store apps", webhook_name: :main)
    end

    def snapshot_query_by_scrape_type(scrape_type)
      if scrape_type == :all
        "display_type != #{IosApp.display_types[:not_ios]}"
      elsif scrape_type == :regular
        { app_store_available: true }
      elsif scrape_type == :new
        previous_week_epf_date = Date.parse(EpfFullFeed.last(2).first.name)
        ['released >= ?', previous_week_epf_date]
      else
        raise UnrecognizedType
      end
    end

    def snapshot_worker_by_scrape_type(scrape_type)
      if scrape_type == :new
        AppStoreInternationalLiveSnapshotWorker
      else
        AppStoreInternationalSnapshotWorker
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

      ids = IosApp.distinct.joins(:ios_app_current_snapshot_backups)
        .where(ios_developer_id: nil)
        .pluck(:id)

      batch.jobs do
        ids.each_slice(1_000) do |slice|
          args = slice.map { |id| [:create_by_ios_app_id, id] }
          SidekiqBatchQueueWorker.perform_async(
            AppStoreDevelopersWorker.to_s,
            args,
            batch.bid
          )
        end
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

    def live_scrape_ios_apps(ios_app_ids, notes: 'international scrape')
      ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create!(notes: notes)
      AppStore.where(enabled: true).each do |app_store|
          AppStoreInternationalLiveSnapshotWorker.perform_async(
            ios_app_current_snapshot_job.id,
            ios_app_ids,
            app_store.id
          )
          AppStoreInternationalSnapshotWorker.perform_async(
            ios_app_current_snapshot_job.id,
            ios_app_ids,
            app_store.id
          )
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

    def execute_table_swaps(automated: false)
      Slackiq.message('Starting table swap', webhook_name: :main)
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

      swap_tables(automated: automated)

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
      Slackiq.message('Successfully completed table swap', webhook_name: :main)
    end

    def swap_tables(automated: false)

      unless automated
        print 'About to swap tables. Are you sure you want to continue? [y/n]: '
        return unless gets.chomp.include?('y')
      end

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

      unless automated
        print 'Does the following query look ok? [y/n] : '
        return unless gets.chomp.include?('y')
      end

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
      AppStoreSnapshotService.run(automated: true) if ServiceStatus.is_active?(:auto_ios_us_scrape)
    end
  rescue AppStoreSnapshotService::InvalidDom
    Slackiq.message('NOTICE: iOS DOM INVALID. CANCELLING APP STORE SCRAPE', webhook_name: :main)
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

    if options['automated']
      self.class.execute_table_swaps(automated: true)
      self.class.app_store_availability(new_store_updates: true)

      # TODO: this technically should happen after table swaps AND new US store scrapes are done
      # Because of how jobs on scrapers are used. this currently works
      if ServiceStatus.is_active?(:auto_ios_mass_scan)
        IosMassScanService.run_recently_released(automated: true)
        IosMassScanService.run_recently_updated(automated: true, n: 2000)
      end
    end
  end

  def on_complete_app_store_availability(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Updated iOS app store availabilities')
  end

end
