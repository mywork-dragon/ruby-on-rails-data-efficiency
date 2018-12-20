# == Schema Information
#
# Table name: android_fb_ad_appearances
#
#  id                        :integer          not null, primary key
#  aws_assignment_identifier :string(191)
#  hit_identifier            :string(191)
#  m_turk_worker_id          :integer
#  android_app_id            :integer
#  heroku_identifier         :string(191)
#  created_at                :datetime
#  updated_at                :datetime
#

class AndroidFbAdAppearance < ActiveRecord::Base
  
  belongs_to :m_turk_worker
  belongs_to :android_app
  
end
