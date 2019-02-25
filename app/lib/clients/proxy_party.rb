module ProxyParty
  class UnsupportedRegion < RuntimeError; end
  class AllRegionsFailed < RuntimeError; end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    include ProxyBase

    # For one off request
    def get_proxy_options(opts:)
      res = {
        http_proxyaddr: nil,
        http_proxyport: nil
      }

      proxy_info = select_proxy(proxy_type: opts[:proxy_type])
      res[:http_proxyaddr], res[:http_proxyport] = proxy_info[:ip], proxy_info[:port]

      if opts[:random_user_agent]
        res[:headers] = opts[:headers] || {}
        res[:headers].merge!(random_browser_header)
      end

      res

    end

    # For modifying the default options on the client
    def proxy_request(proxy_type: nil, region: nil)
      set_proxy(proxy_type: proxy_type, region: region)
      yield
    ensure
      release_proxy
    end

    def set_proxy(proxy_type: :general, region: nil)
      proxy_info = select_proxy(proxy_type: proxy_type, region: region)
      if proxy_info[:user].present?
        http_proxy(proxy_info[:ip], proxy_info[:port], proxy_info[:user], proxy_info[:password])
      else
        http_proxy(proxy_info[:ip], proxy_info[:port])
      end
    end

    def try_all_regions
      # This method accepts a block which makes an
      # http request and retries it in all available
      # regions. If the block's http request fails
      # due to a regional restriction the block must
      # communicate that by throwing ProxyParty::UnsupportedRegion
      regions_available = MicroProxy.where(active:true).uniq.pluck(:region).map {|x| MicroProxy.regions.key(x)}

      # Try general purpose proxies first.
      if regions_available.include? nil
        regions_available.insert(0, regions_available.delete(nil))
      end

      regions_available.each do |region|
        # Try to download via all available proxy regions.
        begin
          return yield region
        rescue ProxyParty::UnsupportedRegion
        rescue Net::OpenTimeout
        rescue Errno::ECONNREFUSED
          Slackiq.message("Connection to proxy in #{region} failed.", webhook_name: :automated_alerts)
        end
      end
      raise ProxyParty::AllRegionsFailed
    end

    def release_proxy
      http_proxy(nil, nil)
    end

    def random_browser_header
      {'User-Agent' => UserAgent.random_web}
    end

  end
end
