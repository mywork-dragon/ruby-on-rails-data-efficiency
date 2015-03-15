class ScraperWorker
  include Sidekiq::Worker

  def perform(name)
    Company.create!(name: name, website: MyIp.ip, status: :active)
  end
end