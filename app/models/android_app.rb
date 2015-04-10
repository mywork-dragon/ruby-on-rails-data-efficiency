class AndroidApp < ActiveRecord::Base

  has_many :android_app_snapshots
  belongs_to :app
  
  has_many :android_apps_snapshots
  has_many :websites, through: :android_apps_snapshots

end
