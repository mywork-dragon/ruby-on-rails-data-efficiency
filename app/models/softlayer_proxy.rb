class SoftlayerProxy < ActiveRecord::Base

  has_many :ios_devices
  has_many :ios_fb_ads

  validates :public_ip, uniqueness: true

  enum host: [:softlayer, :digital_ocean]

end
