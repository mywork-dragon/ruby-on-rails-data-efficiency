class Tag < ActiveRecord::Base
  has_many :tag_relationships
  has_many :ios_sdks, through: :tag_relationships, source: :taggable, source_type: 'IosSdk'
  has_many :android_sdks, through: :tag_relationships, source: :taggable, source_type: 'AndroidSdk'

  has_many :ios_apps, through: :tag_relationships, source: :taggable, source_type: 'IosApp'
  has_many :android_apps, through: :tag_relationships, source: :taggable, source_type: 'AndroidApp'

  has_many :ios_developers, through: :tag_relationships, source: :taggable, source_type: 'IosDeveloper'
  has_many :android_developers, through: :tag_relationships, source: :taggable, source_type: 'AndroidDeveloper'

  validates :name, uniqueness: true
end
