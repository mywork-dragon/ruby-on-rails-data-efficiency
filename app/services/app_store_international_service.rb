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
        return 150
      else
        # Limit batch size to 50 for non "all" scrape types so we 
        # don't receive lock timeout errors from the batch insert.
        return 50 
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

    def scrape_ios_apps(ios_app_ids, notes: 'international scrape', live: false, job: nil)
      ios_app_current_snapshot_job = job || IosAppCurrentSnapshotJob.create!(notes: notes)
      worker = live ? AppStoreInternationalLiveSnapshotWorker : AppStoreInternationalSnapshotWorker
      batch_size = batch_size_by_scrape_type(:new)
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
