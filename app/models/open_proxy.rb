# == Schema Information
#
# Table name: open_proxies
#
#  id         :integer          not null, primary key
#  public_ip  :string(191)
#  username   :string(191)
#  password   :string(191)
#  port       :integer
#  kind       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OpenProxy < ActiveRecord::Base
  enum kind: [:aws_tinyproxy, :digital_ocean_tinyproxy]

  has_many :ios_devices
  has_many :ios_fb_ads
end
