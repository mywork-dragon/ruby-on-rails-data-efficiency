# == Schema Information
#
# Table name: super_proxies
#
#  id         :integer          not null, primary key
#  active     :boolean
#  public_ip  :string(191)
#  private_ip :string(191)
#  port       :integer
#  last_used  :datetime
#  created_at :datetime
#  updated_at :datetime
#

class SuperProxy < ActiveRecord::Base
end
