class IosFbProcessingWorker

  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :ios_fb_ad_processing

  def perform(ios_fb_ad_id)

    begin
      IosFbAd.find(ios_fb_ad_id).update(status: :processing)
      process(ios_fb_ad_id)
      IosFbAd.find(ios_fb_ad_id).update(status: :complete)
      log_event(ios_fb_ad_id)
    rescue => e
      IosFbAdProcessingException.create!({
        ios_fb_ad_id: ios_fb_ad_id,
        error: e.message,
        backtrace: e.backtrace
      })

      IosFbAd.find(ios_fb_ad_id).update(status: :failed)
    else
      ios_fb_ad = IosFbAd.find(ios_fb_ad_id)
      Activity.log_activity(:ad_seen, ios_fb_ad.date_seen, AdPlatform.facebook, ios_fb_ad)
    end
  end

  class FailedLookup < RuntimeError
  end

  def process(ios_fb_ad_id)

    ios_fb_ad = IosFbAd.find(ios_fb_ad_id)

    short_url = get_short_url(ios_fb_ad.link_contents)
    app_identifier = get_app_identifier(short_url)

    ios_app = get_ios_app(app_identifier)

    ios_fb_ad.update(ios_app_id: ios_app.id)
    EwokService.scrape_async(app_identifier: app_identifier, store: :ios)
    EwokService.scrape_international_async(app_identifier: app_identifier, store: :ios)
    IosEpfScanService.scan_apps([ios_app.id], notes: 'running ad intelligence')
  end

  def get_ios_app(app_identifier)
    app = IosApp.find_by_app_identifier(app_identifier)
    app ||= IosApp.create!(app_identifier: app_identifier, source: :ad_intel)
  rescue
    IosApp.find_by_app_identifier!(app_identifier)
  end

  def get_short_url(link_contents)

    match = link_contents.match(/https?:\/\/[^\s]+/)

    raise "Could not get url from link contents: #{link_contents}" unless match

    match[0]
  end

  def get_app_identifier(short_url)

    valid_itunes_url_regex = /https?:\/\/itunes.apple.com.*id(?<id>[\d]+)/

    response = ProxyRequest.get(short_url, random_user_agent: true)

    redirected_url = response.headers['x-apple-orig-url'] # should redirect to itunes page

    raise FailedLookup, "No redirect location available" if redirected_url.blank?

    raise FailedLookup, "Invalid redirect url" unless valid_itunes_url_regex.match(redirected_url)

    app_identifier = valid_itunes_url_regex.match(redirected_url)[:id].to_i

    raise FailedLookup, "Failed to get valid app identifier from #{short_url}" if app_identifier == 0 # to_i returns 0 if not a valid number

    app_identifier

  end

  def log_event(ios_fb_ad_id)
    ad = IosFbAd.find(ios_fb_ad_id)
    RedshiftLogger.new(records: [{
      name: 'ios_ad_found',
      publisher_app_identifier: 284882215, # FB
      advertiser_app_identifier: ad.ios_app.app_identifier,
      created_at: DateTime.now
    }]).send!
  rescue => e
    Bugsnag.notify(e)
  end

  def test_extracting(link_contents)
    short_url = get_short_url(link_contents)
    get_app_identifier(short_url)
  end
end
