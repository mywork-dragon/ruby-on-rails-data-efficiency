class IosTesterServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, queue: :ios_live_scan

  include IosWorker

  def perform(id)
    reserve(id)
  end

  def reserve(id)
    dev = nil
    b = Benchmark.measure do
      dev = reserve_device(:one_off)
    end.real

    puts "Iteration #{id} took #{b} seconds to reserve device #{dev ? dev.id : 'none'}"
  end

  def release_all
    IosDevice.all.each {|x| x.update(in_use: false)}
  end
end
