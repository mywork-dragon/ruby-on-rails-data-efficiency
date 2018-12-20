# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

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
