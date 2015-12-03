class IosSdkFaviconServiceWorker

  include Sidekiq::Worker

  sidekiq_options :retry => 2, queue: :default

  def perform(ios_sdk_id)
    sdk = IosSdk.find(ios_sdk_id)
    favicon = sdk.favicon

    return "Nothing to do" if favicon.nil?

    host = favicon.split('=').last

    new_url = begin
      FaviconService.get_favicon_from_url(url: host, try_backup: true)
    rescue
      favicon
    end

    sdk.update(favicon: new_url) if new_url.present? && URI.parse(new_url)

  end
end