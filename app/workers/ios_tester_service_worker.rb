class IosTesterServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, queue: :ios_live_scan

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
      ios_app_id = 502
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
end
