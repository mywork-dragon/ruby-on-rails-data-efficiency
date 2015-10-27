class CleanDataService

	class << self

		def run

			start = ApkSnapshot.where('scan_status IS NOT NULL').first

			ApkSnapshot.where('id < ?', start.id).each.with_index do |snap, index|

				#puts "app #{index}"

				CleanDataServiceWorker.perform_async(snap.id)

			end

		end

	end

end