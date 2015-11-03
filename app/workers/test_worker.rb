class TestWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :ios_live_scan

  def perform(string)
    puts "*******************TestWorker"
    SidekiqTester.create!(test_string: string, ip: MyIp.ip)
  end
  
end