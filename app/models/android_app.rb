class AndroidApp < ActiveRecord::Base

  has_many :android_app_snapshots
  belongs_to :app

end
