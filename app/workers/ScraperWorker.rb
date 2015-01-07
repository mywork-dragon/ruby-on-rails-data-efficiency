class ScraperWorker
  include Sidekiq::Worker
  include MyIp

  def perform(name, count)
    puts 'Doing hard work'
  end
end