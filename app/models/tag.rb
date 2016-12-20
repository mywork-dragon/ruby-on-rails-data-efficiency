class Tag < ActiveRecord::Base
  has_many :tag_relationships
  has_many :ios_sdks, through: :tag_relationships, source: :taggable, source_type: 'IosSdk'
  has_many :android_sdks, through: :tag_relationships, source: :taggable, source_type: 'AndroidSdk'

  validates :name, uniqueness: true
end
