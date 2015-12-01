# http://www.everymac.com/systems/apple/iphone/index-iphone-specs.html
# http://www.everymac.com/systems/apple/ipod/index-ipod-specs.html

class IosDeviceModel < ActiveRecord::Base

  has_many :ios_devices
  belongs_to :ios_device_family

  validates :name, presence: true, uniqueness: true

end
