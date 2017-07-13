class EpfV3Worker
  include Sidekiq::Worker
  sidekiq_options queue: :epf, retry: 1

  def perform(method_name, *args)
    send(method_name, *args)
  end

  def load_incremental(date=nil)
    epf = EpfApplicationLoader.new(
      source: :epf_incremental,
      trigger_existing_app_scrapes: true,
      trigger_new_app_scrapes: true,
      notify_snapshots_created: true
    )
    epf.import(incremental: true, date: date)
  end

  def load_full(date=nil)
    epf = EpfApplicationLoader.new(
      source: :epf_weekly,
      trigger_existing_app_scrapes: false,
      trigger_new_app_scrapes: true,
      notify_snapshots_created: true
    )
    epf.import(incremental: false, date: date)
    AppStoreInternationalService.run_snapshots(automated: true, scrape_type: :all)
  end

  def notify_snapshots_created(ios_app_current_snapshot_job_id)
  end
end
