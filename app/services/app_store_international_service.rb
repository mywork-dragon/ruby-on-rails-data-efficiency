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
        'last_snapshot_id' => IosAppCurrentSnapshot.last.id
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

    def live_scrape_ios_apps(ios_app_ids, notes: 'international scrape')
      ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create!(notes: notes)
      AppStore.where(enabled: true).each do |app_store|
          AppStoreInternationalLiveSnapshotWorker.perform_async(
            ios_app_current_snapshot_job.id,
            ios_app_ids,
            app_store.id
          )
      end
    end
  end

  def on_complete_snapshots(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Entire App Store Scrape (international) completed', 
     'New Snapshots Added' => IosAppCurrentSnapshot.last.id - options['last_snapshot_id'].to_i)

    if options['automated']
      AppStoreSnapshotService.run(automated: true) if ServiceStatus.is_active?(:auto_ios_us_scrape)

      if ServiceStatus.is_active?(:auto_ios_mass_scan)
        IosMassScanService.run_recently_released(automated: true)
        IosMassScanService.run_recently_updated(automated: true, n: 2000)
      end
    end
  rescue AppStoreSnapshotService::InvalidDom
    Slackiq.message('NOTICE: iOS DOM INVALID. CANCELLING APP STORE SCRAPE', webhook_name: :main)
  end

end
