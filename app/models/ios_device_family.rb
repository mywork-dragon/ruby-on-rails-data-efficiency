# http://www.everymac.com/systems/apple/iphone/index-iphone-specs.html
# http://www.everymac.com/systems/apple/ipod/index-ipod-specs.html

class IosDeviceFamily < ActiveRecord::Base

  has_many :ios_device_models

  validates :name, presence: true, uniqueness: true

end
