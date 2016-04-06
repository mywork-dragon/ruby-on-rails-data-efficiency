class SoftlayerProxy < ActiveRecord::Base

  has_many :ios_devices

  validates :public_ip, uniqueness: true

  enum host: [:softlayer, :digital_ocean]

end
