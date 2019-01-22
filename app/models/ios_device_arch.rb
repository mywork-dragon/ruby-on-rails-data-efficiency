# == Schema Information
#
# Table name: ios_device_arches
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  created_at :datetime
#  updated_at :datetime
#  deprecated :boolean          default(FALSE)
#

class IosDeviceArch < ActiveRecord::Base

  has_many :ios_device_families

  validates :name, presence: true, uniqueness: true

end
