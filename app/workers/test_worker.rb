class TestWorker
  include Sidekiq::Worker

  def perform(string)
    puts "*******************TestWorker"
    SidekiqTester.create!(test_string: string, ip: MyIp.ip)
  end
  
end