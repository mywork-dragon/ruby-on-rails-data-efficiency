class IosAppRelease < ActiveRecord::Base

  has_many :languages
  belongs_to :ios_app
  belongs_to :ios_app_release
  

end
