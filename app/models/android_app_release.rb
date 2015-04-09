class AndroidAppRelease < ActiveRecord::Base

  has_many :languages
  belongs_to :android_app
  
end
