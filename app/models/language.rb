class Language < ActiveRecord::Base

  has_many :ios_app_snapshots_languages
  has_many :ios_app_snapshots, through: :ios_app_snapshots_languages
  
  has_many :android_app_releases

end
