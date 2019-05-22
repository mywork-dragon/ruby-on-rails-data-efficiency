# == Schema Information
#
# Table name: fb_statuses
#
#  id         :integer          not null, primary key
#  status     :text(65535)
#  created_at :datetime
#  updated_at :datetime
#

# Examples from DB:
# You grow up the day you have your first real laugh …………. at yourself
# When people try to bring you down, it just means you’re above them..
# Every sweet has its sour; every evil it`s good..

class FbStatus < ActiveRecord::Base
end
