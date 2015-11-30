class IosTesterServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, queue: :ios_live_scan_cloud # using cloud for get_json

  include IosWorker

  def perform(id)
    # reserve(id)
    check_app(id)
  end

  def reserve(id)
    dev = nil
    b = Benchmark.measure do
      dev = reserve_device(:one_off)
    end.real

    puts "Iteration #{id} took #{b} seconds to reserve device #{dev ? dev.id : 'none'}"
  end

  def check_app(id)

    data = nil
    b = Benchmark.measure do
      ios_app_id = 614758
      data = get_json(ios_app_id)
    end.real

    puts "Iteration #{id} took #{b} seconds to get data: #{data ? 'success' : 'empty'}"
  end

  def release_all
    IosDevice.all.each {|x| x.update(in_use: false)}
  end

  def get_json(ios_app_id)
    begin
      app_identifier = IosApp.find(ios_app_id).app_identifier # TODO, uncomment this
      url = "https://itunes.apple.com/lookup?id=#{app_identifier.to_s}&uslimit=1"

      json = JSON.parse(Proxy.get_body_from_url(url))

      json['results'].first
    rescue
      nil
    end
  end

  def test_proxies(per_proxy: 5)

    return "Proxies not accessible locally" if Rails.env.development?
    uri = URI("https://itunes.apple.com/lookup?id=364297166&uslimit=1")

    proxies = MicroProxy.select(:id, :private_ip).where(active: true)

    proxies.each do |proxy|
      success = 0
      fail = 0
      errors = []

      begin
        res = Proxy.get(req: {host: uri.host + uri.path, protocol: uri.scheme, headers: {'User-Agent' => UserAgent.random_web}}, params: params_from_query(uri.query)) do |curb|
          curb.proxy_url = "#{proxy.private_ip}:8888"
        end
        success += 1
      rescue => e
        fail += 1
        errors.push(e)
      end

      puts "Proxy #{proxy.id} failed #{fail} times out of #{per_proxy}"
      puts "Errors"
      errors.each do |e|
        puts e.message
        puts e.backtrace
      end
    end
  end

  def params_from_query(query)

    return {} if query.nil?

    query.split("&").reduce({}) do |memo, pair|
      parts = pair.split("=")
      if parts.length > 1
        memo[parts.first] = parts.second
        memo
      else
        memo
      end
    end
  end
end
