class IosFbProcessingWorker

  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :ios_fb_ads_cloud

  def perform(ios_fb_ad_id)

    begin
      IosFbAd.find(ios_fb_ad_id).update(status: :processing)

      process(ios_fb_ad_id)

      IosFbAd.find(ios_fb_ad_id).update(status: :complete)
    rescue => e
      IosFbAdProcessingException.create!({
        ios_fb_ad_id: ios_fb_ad_id,
        error: e.message,
        backtrace: e.backtrace
      })

      IosFbAd.find(ios_fb_ad_id).update(status: :failed)
    end
  end

  class FailedLookup < RuntimeError
  end

  def process(ios_fb_ad_id)

    ios_fb_ad = IosFbAd.find(ios_fb_ad_id)

    short_url = get_short_url(ios_fb_ad.link_contents)
    app_identifier = get_app_identifier(short_url)

    ios_app = IosApp.find_by_app_identifier(app_identifier)

    raise "Could not find ios app by app identifier #{app_identifier}" if ios_app.nil?

    ios_fb_ad.update(ios_app_id: ios_app.id)
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

  def test_extracting(link_contents)
    short_url = get_short_url(link_contents)
    get_app_identifier(short_url)
  end
end
