class TestWorker
  include Sidekiq::Worker

  def perform(string)
    li "test_li, #{string}"
    string = "new code! #{@string}"
    SidekiqTester.create!(test_string: string, ip: MyIp.ip)
  end
  
end