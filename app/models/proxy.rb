# == Schema Information
#
# Table name: proxies
#
#  id         :integer          not null, primary key
#  active     :boolean
#  public_ip  :string(191)
#  private_ip :string(191)
#  last_used  :datetime
#  created_at :datetime
#  updated_at :datetime
#

class Proxy < ActiveRecord::Base
  
  validates :private_ip, uniqueness: true
  validates :public_ip, uniqueness: true

end
