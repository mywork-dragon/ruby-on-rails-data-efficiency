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
    AppStoreInternationalService.run_snapshots(scrape_type: :all) if ServiceStatus.is_active?(:auto_ios_intl_scrape)
    AppStoreSnapshotService.run if ServiceStatus.is_active?(:auto_ios_us_scrape)
  end

  def notify_snapshots_created(ios_app_current_snapshot_job_id)
    count = IosSnapshotAccessor.new.job_snapshots_count(ios_app_current_snapshot_job_id)
    Slackiq.message(
      "Snapshots created by job #{ios_app_current_snapshot_job_id}: #{count}",
      webhook_name: :main)
  end
end
