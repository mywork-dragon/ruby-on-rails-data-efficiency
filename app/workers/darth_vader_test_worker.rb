class DarthVaderTestWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :darth_vader

  def perform(string)
    SidekiqTester.create!(test_string: "Don't make me destroy you!", ip: MyIp.ip)
  end
  
end