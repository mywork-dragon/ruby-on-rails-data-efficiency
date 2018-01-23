class GoogleAccount < ActiveRecord::Base

	has_many :apk_snapshots
	has_many :apk_snapshot_exceptions

	enum device: [
    :moto_g_phone_1,
    :moto_g_phone_2,
    :nexus_9_tablet,
    :galaxy_prime_1,
    :galaxy_prime_2,
    :moto_x_1,
    :motog4_1,
    :samsung_galaxy_s7_1
  ]
	enum scrape_type: [:full, :live, :test]

  def user_agent
    dev = device.to_sym
    if [:moto_g_phone_1, :moto_g_phone_2].include?(dev)
      'Android-Finsky/5.5.12 (versionCode=80641200,sdk=22,device=osprey_umts,hardware=qcom,product=osprey_umts,build=LPI23.72-47.4:user'
    elsif dev == :nexus_9_tablet
      'Android-Finsky/6.0.0 (versionCode=80430000,sdk=23,device=floubder,hardware=flounder,product=flounder,build=MRA58N:user'
    elsif [:galaxy_prime_1, :galaxy_prime_2].include?(dev)
      'Android-Finsky/5.10.30 (versionCode=80631600,sdk=22,device=grandprimeve3g,hardware=sc8830,product=grandprimeve3g,build=LMY48B:user'
    elsif [:moto_x_1].include?(dev)
      'Android-Finsky/7.0.17.H-all%20%5B0%5D (api=3,versionCode=80701700,sdk=22,device=ghost,hardware=qcom,product=ghost_retbr,platformVersionRelease=5.1,model=XT1058,buildId=LPA23.12-15,isWideScreen=0)'
    elsif [:motog4_1].include?(dev)
      'Android-Finsky/7.0.17.H-all%20%5B0%5D (api=3,versionCode=80701700,sdk=23,device=athene,hardware=qcom,product=athene_amz,platformVersionRelease=6.0.1,model=Moto%20G%20%284%29,buildId=MPJ24.139-64,isWideScreen=0)'
    elsif [:samsung_galaxy_s7_1].include? dev
      'Android-Finsky/8.5.39.W-all%20%5B0%5D%20%5BPR%5D%20178322352 (api=3,versionCode=80853900,sdk=23,device=heroqltevzw,hardware=qcom,product=heroqltevzw,platformVersionRelease=6.0.1,model=SM-G930V,buildId=MMB29M,isWideScreen=0,supportedAbis=arm64-v8a;armeabi-v7a;armeabi)'
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
