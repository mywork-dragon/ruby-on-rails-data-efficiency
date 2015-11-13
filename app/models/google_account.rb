class GoogleAccount < ActiveRecord::Base

	has_many :apk_snapshots
	has_many :apk_snapshot_exceptions

	enum device: [:moto_g_phone_1, :moto_g_phone_2, :nexus_9_tablet]
	enum scrape_type: [:full, :live]

end
