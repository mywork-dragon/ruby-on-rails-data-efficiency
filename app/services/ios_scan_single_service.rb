class IosScanSingleService

	class << self

		def run(app_identifier)
			IosScanSingleServiceWorker.perform_async(app_identifier)
		end
	end
end
