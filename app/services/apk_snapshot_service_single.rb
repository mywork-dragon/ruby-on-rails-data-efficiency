class ApkSnapshotServiceSingle
  
  class << self
  
  	def run(android_app_id, app_identifier)

      	j = ApkSnapshotJob.create!(notes: app_identifier)

      	favicon = WWW::Favicon.new

  		batch = Sidekiq::Batch.new
		bid = batch.bid

		batch.jobs do
		  ApkSnapshotServiceSingleWorker.perform_async(j.id, bid, android_app_id)
		end

		bid

  	end

  end

end