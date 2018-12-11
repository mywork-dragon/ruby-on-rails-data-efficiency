# == Schema Information
#
# Table name: tag_relationships
#
#  id            :integer          not null, primary key
#  tag_id        :integer
#  taggable_id   :integer
#  taggable_type :string(191)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TagRelationship < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, polymorphic: true
end
