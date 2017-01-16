class AppleEpf

  EPF_URL = 'https://feeds.itunes.apple.com/feeds/epf/v4'

  EPF_USERNAME = ENV['EPF_USERNAME'].to_s
  EPF_PASSWORD = ENV['EPF_PASSWORD'].to_s

  include HTTParty

  base_uri EPF_URL
  basic_auth EPF_USERNAME, EPF_PASSWORD
  format :html

  class FailedRequest < RuntimeError; end

  def self.current_urls
    subpath = '/current/current'
    res = get(subpath)
    raise res.body unless res.code == 200

    page = Nokogiri::HTML(res.body)
    links = page.css('a').map { |x| x['href'] }.compact
    %i(itunes match popularity pricing incremental).reduce({}) do |memo, key|
      link = links.find { |x| /#{key}/.match(x) }
      if link.present?
        memo[key] = File.join(EPF_URL, subpath, link)
      end
      memo
    end
  end

  # use open-uri for binary-data
  def self.download!(epf_file_url, download_path)
    File.open(download_path, 'wb') do |f_local|
      open(epf_file_url, http_basic_authentication: [EPF_USERNAME, EPF_PASSWORD]) do |f_remote|
        IO.copy_stream(f_remote, f_local)
      end
    end
  end
end
