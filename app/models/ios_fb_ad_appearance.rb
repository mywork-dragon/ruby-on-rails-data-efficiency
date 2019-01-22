# == Schema Information
#
# Table name: ios_fb_ad_appearances
#
#  id                        :integer          not null, primary key
#  aws_assignment_identifier :string(191)
#  hit_identifier            :string(191)
#  heroku_identifier         :integer
#  m_turk_worker_id          :integer
#  ios_app_id                :integer
#  created_at                :datetime
#  updated_at                :datetime
#

class IosFbAdAppearance < ActiveRecord::Base
  
  belongs_to :m_turk_worker
  belongs_to :ios_app
    
end
