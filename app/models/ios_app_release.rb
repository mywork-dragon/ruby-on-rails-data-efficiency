class IosAppRelease < ActiveRecord::Base

  has_many :languages
  belongs_to :ios_app
  
end
