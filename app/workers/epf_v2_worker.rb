# DEPRECATED - now using combination of airflow and EpfApplicationLoader
class EpfV2Worker
  include Sidekiq::Worker
  sidekiq_options queue: :epf, retry: false

  class MalformedFilename < RuntimeError; end

  def perform(method_name, *args)
    send(method_name, *args)
  end

  def run_epf_if_feed_available
    if new_feed_available?
      Slackiq.message("A new EPF feed is available!", webhook_name: :main)
      EpfFullFeed.create!(name: current_feed_name)
      queue_application_loading
    else
      Slackiq.message("There is no new EPF Feed available. Guess we'll try again tomorrow.", webhook_name: :main)
    end
  end

  def new_feed_available?
    last_feed_date = Date.parse(EpfFullFeed.last.name)
    Date.parse(current_feed_name) > last_feed_date
  end

  def current_feed_name
    urls = AppleEpf.current_urls
    itunes_file_name = urls[:itunes].split('/').last
    date_match = /itunes(\d+)/.match(itunes_file_name)
    raise MalformedFilename unless date_match
    date_match[1]
  end

  def queue_application_loading
    batch = Sidekiq::Batch.new
    batch.description = "EPF V2 - Load Applications"
    batch.on(
      :complete,
      'EpfV2Worker#on_complete_applications',
      'last_ios_app_id' => IosApp.last.id
    )

    batch.jobs do
      EpfV2Worker.perform_async(:load_applications)
    end
  end

  def load_applications
    EpfFullApplicationReader.new.execute
  end

  def on_complete_applications(status, options)
    last_ios_app_id = options['last_ios_app_id'].to_i
    Slackiq.notify(
      webhook_name: :main,
      status: status,
      title: 'Finished EPF Application import',
      'Apps Added' => IosApp.where('id > ?', last_ios_app_id).count
    )

    puts 'Kicking off new apps scrape'
    AppStoreSnapshotService.run_new_apps(notes: "Run new apps #{Time.now.strftime("%m/%d/%Y")}")

    if ServiceStatus.is_active?(:auto_ios_intl_scrape)
      AppStoreInternationalService.run_snapshots(automated: true, scrape_type: :all)
    else
      AppStoreInternationalService.run_snapshots(scrape_type: :new)
    end
  rescue AppStoreSnapshotService::InvalidDom
    Slackiq.message('NOTICE: iOS DOM INVALID. CANCELLING NEW APPS SCRAPE', webhook_name: :main)
  end
end
