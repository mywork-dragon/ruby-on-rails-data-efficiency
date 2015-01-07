class ScraperWorker
  include Sidekiq::Worker
  include MyIp

  def perform(name, count)
    Company.create!(name: "ababksjbfakjbsfkjabskfjbakjsbf124124.edu", url: "http://ababksjbfakjbsfkjabskfjbakjsbf124124.edu", status: :active)
  end
end