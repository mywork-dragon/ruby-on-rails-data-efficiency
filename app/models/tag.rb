class Tag < ActiveRecord::Base
  has_many :tag_relationships
  has_many :ios_sdks, through: :tag_relationships, source: :taggable, source_type: 'IosSdk'

  validates :name, uniqueness: true
end