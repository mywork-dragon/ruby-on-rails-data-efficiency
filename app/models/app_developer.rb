# == Schema Information
#
# Table name: app_developers
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  flagged    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AppDeveloper < ActiveRecord::Base
  has_many :app_developers_developers
  has_many :ios_developers, through: :app_developers_developers, source: :developer, source_type: 'IosDeveloper'
  has_many :android_developers, through: :app_developers_developers, source: :developer, source_type: 'AndroidDeveloper'

  def as_json(options = {})
    {
      id: id,
      name: name,
      ios_publishers: ios_developers.map {|d| d.api_json(short_form: true)},
      android_publishers: android_developers.map {|d| d.api_json(short_form: true)}
    }
  end
end
