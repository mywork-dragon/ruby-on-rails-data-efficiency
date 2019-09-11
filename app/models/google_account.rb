# == Schema Information
#
# Table name: google_accounts
#
#  id                 :integer          not null, primary key
#  email              :string(191)
#  password           :string(191)
#  android_identifier :string(191)
#  proxy_id           :integer
#  blocked            :boolean
#  flags              :integer
#  last_used          :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  in_use             :boolean
#  device             :integer
#  scrape_type        :integer          default(0)
#  auth_token         :string(191)
#

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
    :samsung_galaxy_s7_1,
    :samsung_galaxy_s7_2,
    :google_pixel_2
  ]
	enum scrape_type: [:full, :live, :test]

  def user_agent
    dev = device.to_sym
    if [:moto_g_phone_1, :moto_g_phone_2].include?(dev)
      'Android-Finsky/9.2.11-all (versionCode=80921100,sdk=22,device=osprey_umts,hardware=qcom,product=osprey_umts,build=LPI23.72-47.4:user'
    elsif dev == :nexus_9_tablet
      'Android-Finsky/6.2.13.A-all (versionCode=2655766,sdk=23,device=floubder,hardware=flounder,product=flounder,build=MRA58N:user'
    elsif [:galaxy_prime_1, :galaxy_prime_2].include?(dev)
      'Android-Finsky/10.4.13-all (versionCode=81041300,sdk=22,device=grandprimeve3g,hardware=sc8830,product=grandprimeve3g,build=LMY48B:user'
    elsif [:moto_x_1].include?(dev)
      'Android-Finsky/9.9.21-all (api=3,versionCode=80992100,sdk=22,device=ghost,hardware=qcom,product=ghost_retbr,platformVersionRelease=5.1,model=XT1058,buildId=LPA23.12-15,isWideScreen=0)'
    elsif [:motog4_1].include?(dev)
      'Android-Finsky/10.8.50-all (api=3,versionCode=81085000,sdk=23,device=athene,hardware=qcom,product=athene_amz,platformVersionRelease=6.0.1,model=Moto%20G%20%284%29,buildId=MPJ24.139-64,isWideScreen=0)'
    elsif [:samsung_galaxy_s7_1].include? dev
      'Android-Finsky/12.2.31-all (api=3,versionCode=81223100,sdk=23,device=heroqltevzw,hardware=qcom,product=heroqltevzw,platformVersionRelease=6.0.1,model=SM-G930V,buildId=MMB29M,isWideScreen=0,supportedAbis=arm64-v8a;armeabi-v7a;armeabi)'
    elsif [:samsung_galaxy_s7_2].include? dev
      'Android-Finsky/13.4.11-all (api=3,versionCode=81341100,sdk=27,device=heroqltevzw,hardware=qcom,product=heroqltevzw,platformVersionRelease=6.0.1,model=SM-G930V,buildId=MMB29M,isWideScreen=0,supportedAbis=arm64-v8a;armeabi-v7a;armeabi)'
    elsif [:google_pixel_2].include? dev
      'Android-Finsky/16.2.25-all (api=3,versionCode=81622500,sdk=28, product=walleye,device=walleye,buildId=PPP3.180510.008,build=4811556:user,platformVersionRelease=9,model=Pixel%202,supportedAbis=arm64-v8a,armeabi-v7a,armeabi)'
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
