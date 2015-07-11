class TestSdkWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :sdk

  def perform(string)
    puts "*******************TestSdkWorker"
    SidekiqTester.create!(test_string: "sdk", ip: MyIp.ip)
  end
  
end