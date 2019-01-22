# == Schema Information
#
# Table name: follow_relationships
#
#  id              :integer          not null, primary key
#  followable_id   :integer          not null
#  followable_type :string(191)      not null
#  created_at      :datetime
#  updated_at      :datetime
#  follower_id     :integer
#  follower_type   :string(191)
#

class FollowRelationship < ActiveRecord::Base
  belongs_to :follower, polymorphic: true
  belongs_to :followable, polymorphic: true
end
