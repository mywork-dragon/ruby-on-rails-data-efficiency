class Language < ActiveRecord::Base

  has_many :ios_app_releases
  has_many :android_app_releases

end
