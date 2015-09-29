class CleanService

	class << self

		def delete_dupes
		
			AndroidSdkCompaniesApkSnapshot.all.each do |row|

				android_sdk_company_id = row.android_sdk_company_id

				apk_snapshot_id = row.apk_snapshot_id

				ascas = AndroidSdkCompaniesApkSnapshot.where(android_sdk_company_id: android_sdk_company_id, apk_snapshot_id: apk_snapshot_id)

				if ascas.count > 1

					ascas.each do |r|

						r.delete if r.id != row.id

					end

				end

			end

		end

	end

end