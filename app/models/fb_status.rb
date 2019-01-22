# == Schema Information
#
# Table name: fb_statuses
#
#  id         :integer          not null, primary key
#  status     :text(65535)
#  created_at :datetime
#  updated_at :datetime
#

class FbStatus < ActiveRecord::Base  
end
