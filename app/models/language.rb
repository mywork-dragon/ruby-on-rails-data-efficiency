class Language < ActiveRecord::Base

  has_many :ios_app_snapshots, through: :ios_snapshot_languages
  has_many :android_app_releases

end
