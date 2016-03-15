# http://www.everymac.com/systems/apple/iphone/index-iphone-specs.html
# http://www.everymac.com/systems/apple/ipod/index-ipod-specs.html

class IosDeviceFamily < ActiveRecord::Base

  has_many :ios_device_models
  has_many :ios_devices, through: :ios_device_models
  belongs_to :ios_device_arch

  validates :name, presence: true, uniqueness: true

end
