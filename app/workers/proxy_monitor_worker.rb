class ProxyMonitorWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :scraper

  TEST_SITES = [
    'https://www.apple.com',
    'https://www.google.com',
    'https://wtfismyip.com/json'
  ]

  def perform(method, args*)
    self.send(method.to_sym, args)
  end

  def test_microproxy(micro_proxy_id)
    proxy = MicroProxy.find(micro_proxy_id)

    puts "Trying proxy #{proxy.id}: #{proxy.private_ip}"

    # just make sure any of the sites work
    resp = nil
    while resp.nil?
      TEST_SITES.each do |site|
        resp = begin
          Proxy.get_from_url(site, proxy: proxy.private_ip)
        rescue Curl::Err::TimeoutError
          nil
        end
      end
    end

    return if resp

    proxy.update(active: false)
    Slackiq.message("MicroProxy #{proxy.id} failed health check. Disabling", webhook_name: :automated_alerts)
  end
end