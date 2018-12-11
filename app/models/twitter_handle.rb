# == Schema Information
#
# Table name: twitter_handles
#
#  id         :integer          not null, primary key
#  handle     :string(191)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TwitterHandle < ActiveRecord::Base
  has_many :owner_twitter_handles
end
