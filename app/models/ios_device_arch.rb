class IosDeviceArch < ActiveRecord::Base

  has_many :ios_device_families

  validates :name, presence: true, uniqueness: true

end
