class GoogleAccount < ActiveRecord::Base

	has_many :apk_snapshots
	has_many :apk_snapshot_exceptions

	enum device: [:moto_g_phone_1, :moto_g_phone_2, :nexus_9_tablet]
	enum scrape_type: [:full, :live, :test]


  class << self

    def full_scan_active_accounts(max_flags: 10)
      GoogleAccount.where(blocked: false, scrape_type: :full).where("flags <= ?", max_flags)
    end

  end

end
