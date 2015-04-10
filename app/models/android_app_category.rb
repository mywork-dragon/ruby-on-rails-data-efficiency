class AndroidAppCategory < ActiveRecord::Base

  has_many :android_app_categories_snapshots
  has_many :android_app_snapshots, through: :android_app_categories_snapshots

end
