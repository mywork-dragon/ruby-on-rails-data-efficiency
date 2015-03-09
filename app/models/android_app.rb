class AndroidApp < ActiveRecord::Base

  has_many :android_app_releases
  belongs_to :app

end
