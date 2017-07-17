# Loads EPF entries into DB using JSON delimited EPF file from Feeds
class EpfApplicationLoader

  attr_accessor :http_client

  def initialize(options={})
    @options = options
    @token = options[:token] || ENV['MS_FEEDS_TOKEN'].to_s
    @source = options[:source]
    @http_client = HTTParty
    @snapshot_job = nil
  end

  def snapshot_job
    return @snapshot_job if @snapshot_job
    @snapshot_job = IosAppCurrentSnapshotJob.create!(notes: 'Scraping new apps in EPF')
  end

  # streaming after redirecting is causing invalid gzip errors, so will extract redirect url and download directly
  def get_url_for_date(date, incremental)
    type = incremental ? 'incremental' : 'full'
    res = http_client.get(
      "https://feeds.mightysignal.com/v1/internal/epf/#{type}/application/#{date}/application.gz",
      headers: { 'JWT' => @token },
      follow_redirects: false
    )
    raise RuntimeError, res.code unless res.code >= 300 and res.code < 400 # assert redirect

    res.headers['location']
  end

  def download(url)
    tmp = File.join('/tmp', Digest::SHA1.hexdigest(url))
    File.open(tmp, 'wb') do |f|
      http_client.get(url, stream_body: true) do |fragment|
        f.write(fragment)
      end
    end
    tmp
  end

  def parse_file(path)
    existing_identifiers = Set.new(IosApp.pluck(:app_identifier))
    new_apps = []
    new_apps_index = 0
    existing_apps_index = 0
    existing_app_identifiers = []
    Zlib::GzipReader.open(path).each_line do |line|
      entry = begin
                JSON.parse(line)
              rescue JSON::ParserError
                nil
              end

      next if entry.nil? || entry['application_id'].to_i == 0
      
      if existing_identifiers.include?(entry['application_id'].to_i)
        existing_apps_index += 1
        existing_app_identifiers << entry['application_id'].to_i
        if existing_app_identifiers.count >= 1_000
          trigger_existing_app_scrapes(existing_app_identifiers) if @options[:trigger_existing_app_scrapes]
          existing_app_identifiers = []
        end
      else
        new_apps << IosApp.new(
          app_identifier: entry['application_id'].to_i,
          released: DateTime.strptime(entry['itunes_release_date'], '%Y-%m-%d'),
          source: @source
        )
        new_apps_index += 1
        if new_apps.count >= 1_000
          puts "New Application ##{new_apps_index}"
          IosApp.import new_apps.compact
          trigger_new_app_scrapes(new_apps) if @options[:trigger_new_app_scrapes]
          new_apps = []
        end
      end
    end

    if new_apps.count > 0
      IosApp.import new_apps.compact
      trigger_new_app_scrapes(new_apps) if @options[:trigger_new_app_scrapes]
    end

    if existing_app_identifiers.count > 0
      trigger_existing_app_scrapes(existing_app_identifiers) if @options[:trigger_existing_app_scrapes]
    end

    puts "Added #{new_apps_index} apps"
    puts "Found #{existing_apps_index} existing apps"
    {
      new_apps_count: new_apps_index,
      existing_apps_count: existing_apps_index
    }
  end

  # incremental is a boolean
  # date is a DateTime or Date object
  def import(incremental:, date: nil)
    date_string = date.present? ? date.strftime('%Y-%m-%d') : 'latest'
    url = get_url_for_date(date_string, incremental)
    path = download(url)
    parse_file(path)
    if @options[:notify_snapshots_created] && @snapshot_job.present?
      EpfV3Worker
        .set(queue: :ios_international_scrape)
        .perform_async(:notify_snapshots_created, @snapshot_job.id)
    end
  ensure
    FileUtils.rm([path]) if defined?(path) && path
  end

  def trigger_new_app_scrapes(rows)
    ids = IosApp.where(app_identifier: rows.map(&:app_identifier)).pluck(:id)
    AppStoreInternationalService.scrape_ios_apps(ids, job: snapshot_job, batch_size: 25)
  end

  # this is pretty dumb for now. If causes too much load, might consider
  # comparing against itunes version of EPF record
  def trigger_existing_app_scrapes(app_identifiers)
    ids = IosApp
      .where(app_identifier: app_identifiers)
      .where.not(display_type: IosApp.display_types[:not_ios])
      .pluck(:id)
    AppStoreInternationalService.scrape_ios_apps(ids, job: snapshot_job, batch_size: 150)
  end
end
