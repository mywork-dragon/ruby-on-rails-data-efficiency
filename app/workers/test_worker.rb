class TestWorker
  include Sidekiq::Worker
  
  sidekiq_options :queue => :critical

  def perform(string)
    # li "test_li, #{string}"
#     SidekiqTester.create!(test_string: string, ip: MyIp.ip)
    
    SidekiqTester.create!(test_string: "critical")
  end
  
end