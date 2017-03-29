class OpenProxy < ActiveRecord::Base
  enum kind: [:aws_tinyproxy, :digital_ocean_tinyproxy]

  has_many :ios_devices
  has_many :ios_fb_ads
end
