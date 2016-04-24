class GoogleAccount < ActiveRecord::Base

	has_many :apk_snapshots
	has_many :apk_snapshot_exceptions

	enum device: [:moto_g_phone_1, :moto_g_phone_2, :nexus_9_tablet, :galaxy_prime_1, :galaxy_prime_2]
	enum scrape_type: [:full, :live, :test]

  def user_agent
    dev = device.to_sym
    if [:moto_g_phone_1, :moto_g_phone_2].include?(dev)
      'Android-Finsky/5.5.12 (versionCode=80641200,sdk=22,device=osprey_umts,hardware=qcom,product=osprey_umts,build=LPI23.72-47.4:user'
    elsif dev == :nexus_9_tablet
      'Android-Finsky/6.0.0 (versionCode=80430000,sdk=23,device=floubder,hardware=flounder,product=flounder,build=MRA58N:user'
    elsif [:galaxy_prime_1, :galaxy_prime_2].include?(dev)
      'Android-Finsky/5.10.30 (versionCode=80631600,sdk=22,device=grandprimeve3g,hardware=sc8830,product=grandprimeve3g,build=LMY48B:user'
    else
      fail 'No User-Agent'
    end
  end

  class << self

    def full_scan_active_accounts(max_flags: 10)
      GoogleAccount.where(blocked: false, scrape_type: :full).where("flags <= ?", max_flags)
    end

  end

end
