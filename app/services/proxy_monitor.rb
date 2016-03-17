class ProxyMonitor
  class << self
    def check_proxies

      batch = Sidekiq::Batch.new
      batch.description = "Checking reachability of proxies" 
      batch.on(:complete, 'ProxyMonitor#on_complete')

      batch.jobs do
        MicroProxy.where(active: true).find_each do |proxy|
          ProxyMonitorWorker.perform_async(:test_microproxy, proxy.id)
        end
      end
    end
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :debug, status: status, title: 'checked proxies')
  end
end