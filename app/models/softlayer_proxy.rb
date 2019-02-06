# == Schema Information
#
# Table name: softlayer_proxies
#
#  id         :integer          not null, primary key
#  public_ip  :string(191)
#  created_at :datetime
#  updated_at :datetime
#  host       :integer
#

class SoftlayerProxy < ActiveRecord::Base

  has_many :ios_devices
  has_many :ios_fb_ads

  validates :public_ip, uniqueness: true

  enum host: [:softlayer, :digital_ocean]

end
