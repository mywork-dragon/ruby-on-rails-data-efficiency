class CleanDataServiceWorker

	include Sidekiq::Worker

	sidekiq_options queue: :default

	def perform(snap_id)

		snap = ApkSnapshot.find(snap_id)

		aa = snap.android_app

		if aa.newest_apk_snapshot_id == snap_id
			aa.newest_apk_snapshot_id = nil
			aa.save
		end

		snap.delete

	end

end