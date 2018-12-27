# == Schema Information
#
# Table name: m_turk_workers
#
#  id                :integer          not null, primary key
#  aws_identifier    :string(191)
#  age               :integer
#  gender            :string(191)
#  city              :string(191)
#  state             :string(191)
#  country           :string(191)
#  iphone            :string(191)
#  ios_version       :string(191)
#  heroku_identifier :string(191)
#  created_at        :datetime
#  updated_at        :datetime
#

class MTurkWorker < ActiveRecord::Base

  has_many :ios_fb_ad_appearances
  has_many :android_fb_ad_appearances
  

end
