class AdPlatform < ActiveRecord::Base
  has_many :weekly_batches, as: :owner

  def as_json(options={})
    {
      id: self.id,
      type: self.class.name,
      platform: self.platform,
      icon: self.icon_url
    }
  end

  def icon_url
    IosApp.where(id: 873833).first.try(:icon_url) || 'http://a4.mzstatic.com/us/r30/Purple49/v4/c2/9f/8e/c29f8ea8-64a5-de67-8534-df55f50b8a99/icon350x350.jpeg'
  end

  def self.facebook
    AdPlatform.find_or_create_by(platform: 'Facebook')
  end
end
