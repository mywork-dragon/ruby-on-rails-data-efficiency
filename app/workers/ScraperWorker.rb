class ScraperWorker
  include Sidekiq::Worker
  include MyIp

  def perform(name, count)
    log = Logger.new '/home/deploy/varys_current/logs/resque.log'
    log.debug "before create"
    Company.create!(name: "dummy5432112345.edu", website: "http://dummy5432112345.edu", status: :active)
    log.debug "after create"
  end
end