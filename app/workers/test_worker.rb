class TestWorker
  include Sidekiq::Worker

  def perform(string)
    SidekiqTester.create!(test_string: string, ip: MyIp.ip)
  end
  
  def test_li(string)
    li "test_li, #{string}"
    SidekiqTester.create!(test_string: string, ip: MyIp.ip)
  end
end