class AppDeveloper < ActiveRecord::Base
  has_many :app_developers_developers
  has_many :ios_developers, through: :app_developers_developers, source: :developer, source_type: 'IosDeveloper'
  has_many :android_developers, through: :app_developers_developers, source: :developer, source_type: 'AndroidDeveloper'
end
