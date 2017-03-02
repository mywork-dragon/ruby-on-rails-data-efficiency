class CocoapodMetricsApi

  include HTTParty
  include ProxyParty

  base_uri 'http://metrics.cocoapods.org/api/v1'

  def self.metrics(pod_name)
    proxy_request do
      JSON.parse(get("/pods/#{pod_name}.json").body)
    end
  end

end
