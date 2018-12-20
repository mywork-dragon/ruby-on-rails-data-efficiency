# == Schema Information
#
# Table name: micro_proxies
#
#  id         :integer          not null, primary key
#  active     :boolean
#  public_ip  :string(191)
#  private_ip :string(191)
#  last_used  :date
#  created_at :datetime
#  updated_at :datetime
#  purpose    :integer
#  region     :integer
#

class MicroProxy < ActiveRecord::Base
	has_many :apk_snapshots

  enum purpose: [:general, :ios, :android, :region]

  include ProxyRegions
end
