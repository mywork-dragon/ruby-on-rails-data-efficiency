class IosDeviceModel < ActiveRecord::Base

  has_many :ios_devices
  belongs_to :ios_device_family

end
