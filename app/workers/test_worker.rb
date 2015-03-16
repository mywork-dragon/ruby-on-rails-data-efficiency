class TestWorker
  include Sidekiq::Worker

  def perform(string)
    SidekiqTester.create!(test_string: string, MyIp.ip)
  end
end