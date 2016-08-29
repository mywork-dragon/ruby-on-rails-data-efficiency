class TestWorker
  include Sidekiq::Worker
  
  # sidekiq_options queue: :ios_live_scan
  sidekiq_options queue: :maul

  def perform(string)
    puts "*******************TestWorker"
    SidekiqTester.create!(test_string: "MAUL", ip: MyIp.ip)
  end
  
end