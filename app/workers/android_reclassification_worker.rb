class AndroidReclassificationWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sidekiq_batcher

  def perform
    ActiveRecord::Base.connection.execute("select id from apk_snapshots where status = 1 ").each do |id|
      AndroidClassificationServiceWorker.perform_async(id[0])
    end
  end

end

