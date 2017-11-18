class AppStoreInternationalService

  class UnrecognizedType < RuntimeError; end

  class << self

    def run_snapshots(automated: false, scrape_type: :all)
      batch = Sidekiq::Batch.new
      batch.description = "AppStoreInternationalService.run_snapshots" 
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_snapshots',
        'automated' => automated,
        'last_snapshot_id' => IosAppCurrentSnapshot.last.id,
        'notification_title' => notification_title_by_scrape_type(scrape_type)
      )

      Slackiq.message('Starting to queue iOS international apps', webhook_name: :main)
      notes = "Full scrape (international) #{Time.now.strftime("%m/%d/%Y")}"
      j = IosAppCurrentSnapshotJob.create!(notes: notes)

      query = snapshot_query_by_scrape_type(scrape_type)
      snapshot_worker = snapshot_worker_by_scrape_type(scrape_type)

      enabled_app_store_ids = AppStore.where(enabled: true).pluck(:id)
      batch_size = batch_size_by_scrape_type(scrape_type)

      ids = IosApp.where(query).pluck(:id)
      batch.jobs do
        ids.each_slice(batch_size) do |slice|
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

    def batch_size_by_scrape_type(scrape_type)
      if scrape_type == :all
        150
      else
        # Limit batch size to 50 for non "all" scrape types so we 
        # don't receive lock timeout errors from the batch insert.
        50
      end
    end

    def notification_title_by_scrape_type(scrape_type)
      if scrape_type == :all
        return 'Entire App Store Scrape (international) completed'
      else
        return 'New App Store Scrape (international) completed'
      end
    end

    def snapshot_query_by_scrape_type(scrape_type)
      if scrape_type == :all
        "display_type != #{IosApp.display_types[:not_ios]}"
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

    def start_scrape_from_newcomer_rankings
      page_size = 1000
      lookback_time = 1.days.ago

      rankings_accessor = RankingsAccessor.new
      ios_snapshot_accessor = IosSnapshotAccessor.new

      count_result = rankings_accessor.unique_newcomers(platform: "ios", lookback_time: 1.days.ago, page_size: page_size, page_num: 1, count: true)
      num_pages = (count_result / page_size) + 1

      snapshot_job = IosAppCurrentSnapshotJob.create!(notes: "Scrape from Newcomer Rankings #{Time.now.strftime("%m/%d/%Y")}")

      (1..num_pages).each do |page_num|
        page_result = rankings_accessor.unique_newcomers(platform: "ios", lookback_time: 1.days.ago, page_size: page_size, page_num: page_num)
        newcomer_app_identifiers = page_result.map { |row| row["app_identifier"] }

        # For each newcomer app, check if they have an entry in the ios_apps table. Create entry if missing.

        existing = IosApp.where(app_identifier: newcomer_app_identifiers).to_a

        missing_ios_app_entry_identifiers = newcomer_app_identifiers.map(&:to_i) - existing.map(&:app_identifier)
        missing_ios_app_entries = missing_ios_app_entry_identifiers.map do |app_identifier|
          IosApp.new(
            app_identifier: app_identifier,
            source: :rankings 
          )
        end

        IosApp.import!(
          missing_ios_app_entries,
          synchronize: missing_ios_app_entries,
          synchronize_keys: [:app_identifier]
        )

        # For each of the existing apps, check if there's an international snapshot. For the apps without a snapshot,
        # add to the scrape list.
        existing_app_ids = existing.map(&:id)
        app_ids_with_snapshot = ios_snapshot_accessor.app_ids_with_latest_snapshot(existing_app_ids)
        app_ids_missing_snapshots = existing_app_ids - app_ids_with_snapshot

        app_ids_to_scrape = missing_ios_app_entries.map(&:id) + app_ids_missing_snapshots
        
        scrape_ios_apps(app_ids_to_scrape, live: true, job: snapshot_job)
      end
    end

    def scrape_ios_apps(ios_app_ids, notes: 'international scrape', live: false, job: nil, batch_size: nil)
      ios_app_current_snapshot_job = job || IosAppCurrentSnapshotJob.create!(notes: notes)
      worker = live ? AppStoreInternationalLiveSnapshotWorker : AppStoreInternationalSnapshotWorker
      batch_size ||= batch_size_by_scrape_type(:new)
      store_ids = AppStore.where(enabled: true).pluck(:id)

      args = store_ids.map do |app_store_id|
        ios_app_ids.each_slice(batch_size).map do |ios_app_id_group|
          [ios_app_current_snapshot_job.id, ios_app_id_group, app_store_id]
        end
      end.inject(:+)

      Sidekiq::Client.push_bulk('class' => worker, 'args' => args)
    end
  end

  def on_complete_snapshots(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: options['notification_title'], 
     'New Snapshots Added' => IosAppCurrentSnapshot.last.id - options['last_snapshot_id'].to_i)
  end

end
