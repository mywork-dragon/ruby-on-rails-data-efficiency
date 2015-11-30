class IosTesterService

  class << self

    include IosWorker

    def test_reserve
      8.times.map do |x|
        dev = nil
        b = Benchmark.measure do
          dev = reserve_device(:one_off)
        end.real

        puts "Iteration #{x} took #{b} seconds to reserve device #{dev ? dev.id : 'none'}"
      end
    end
  end
end
