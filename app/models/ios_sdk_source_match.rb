# == Schema Information
#
# Table name: ios_sdk_source_matches
#
#  id            :integer          not null, primary key
#  source_sdk_id :integer
#  match_sdk_id  :integer
#  collisions    :integer
#  total         :integer
#  ratio         :float(24)
#  created_at    :datetime
#  updated_at    :datetime
#

class IosSdkSourceMatch < ActiveRecord::Base
  belongs_to :source_sdk, class_name: 'IosSdk'
  belongs_to :match_sdk, class_name: 'IosSdk'
end
