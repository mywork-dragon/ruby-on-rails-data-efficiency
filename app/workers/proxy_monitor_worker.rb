class ProxyMonitorWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :monitor

  TEST_SITES = [
    'https://www.apple.com',
    'https://www.google.com',
    'https://github.com/'
  ]

  MAX_ATTEMPTS = 3

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def test_microproxy(micro_proxy_id)
    proxy = MicroProxy.find(micro_proxy_id)

    puts "Trying proxy #{proxy.id}: #{proxy.private_ip}"

    # just make sure at least one of the sites work
    resp = nil
    attempts = 0
    while resp.nil? && attempts < MAX_ATTEMPTS

      attempts += 1

      resp = begin
        site = TEST_SITES.sample
        puts "#{proxy.id}: #{site}"
        Proxy.get_from_url(site, proxy: proxy.private_ip)
      rescue Curl::Err::TimeoutError
        nil
      end

    end

    return if resp

    proxy.update(active: false)
    Slackiq.message("MicroProxy #{proxy.id} failed health check. Disabling", webhook_name: :automated_alerts)
  end
end