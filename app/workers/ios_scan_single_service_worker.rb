class IosScanSingleServiceWorker

	include Sidekiq::Worker

	sidekiq_options backtrace: true, queue: :ios_live_scan

	include IosWorker

	def perform(app_identifier)
		run_scan(app_identifier, :one_off)
	end

end