class ScraperWorker
  include Sidekiq::Worker
  include MyIp

  def perform(name, count)
    Company.create!(name: "dummy5432112345.edu", website: "http://dummy5432112345.edu", status: :active)
  end
end