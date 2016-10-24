class MightyBot

  def initialize
    prepare_client
  end

  def post_status_with_gif(text:, gif_url:)
    res = nil
    download_gif(gif_url) do |filepath|
      File.open(filepath) do |f_io|
        res = @client.update_with_media(text, f_io)
      end
    end
    res
  end

  def post_status(text)
    @client.update(text)
  end

  def search_for_account(name)
    res = @client.user_search(name, count: 1)
    res.first.screen_name if res && res.first
  end

  private

  def download_gif(url)
    localfile = "/tmp/#{Digest::MD5.hexdigest(url)}.gif"
    open(localfile, 'wb') do |f_local|
      open(url) do |f_remote|
        IO.copy_stream(f_remote, f_local)
      end
    end
    yield(localfile)
  ensure
    File.delete(localfile) if localfile && File.exist?(localfile)
  end

  def prepare_client
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = api_key
      config.consumer_secret     = api_secret
      config.access_token        = access_token
      config.access_token_secret = access_token_secret
    end
  end

  def api_key
    'ZNB6FwUTZo0evgv2GgYhiInyQ'
  end

  def api_secret
    '1RreoRcjxJSuk1WhujHZSKGF2kXYlfyPuwm3s72cFpKpIXlmMy'
  end

  def access_token
    '766340357546242048-6HhEPqdN1dl1S2MPMyLxLmy7iKevQYm'
  end

  def access_token_secret
    '6nW7MRZ9Jv7q6UdofZpuxjMjlgvDpycBYyWWUJMl2Qyis'
  end
  # def self.search_sdk_handles
  #   regex = %r{https://www.twitter.com/([^/]+)}
  #   IosSdk.select(:id, :name).joins(:tag_relationships).where(id: 67).each do |sdk|
  #     matching_url = SdkService.google_search(q: sdk.name, site: 'twitter.com', limit: 10).find do |url|
  #       regex.match(url)
  #     end
  #     next unless matching_url
  #     handle = regex.match(matching_url)[1]
  #     handle_row = TwitterHandle.find_or_create!(handle: handle)
  #     OwnerTwitterHandle.create!(
  #       owner: sdk,
  #       twitter_handle: handle_row
  #     )
  #   end
  # end

  # def self.import(add: false)
  #   contents = File.open('/tmp/list.txt') {|f| f.read }
  #   lines = contents.split(/\n/)
  #   lines.each do |line|
  #     parts = line.split(/\t/)
  #     next unless parts.count == 3
  #     puts "#{parts.second} --> #{parts.third}"
  #     next unless add
  #     sdk = IosSdk.find(parts.first)
  #     handle = TwitterHandle.find_or_create_by(handle: parts.third)
  #     OwnerTwitterHandle.find_or_create_by(
  #       owner: sdk,
  #       twitter_handle: handle
  #     )
  #   end
  # end
end
