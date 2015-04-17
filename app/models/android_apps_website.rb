class AndroidAppsWebsite < ActiveRecord::Base

  belongs_to :android_app
  belongs_to :website

end
