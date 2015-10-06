class AndroidAppSnapshot < ActiveRecord::Base

  belongs_to :android_app
  belongs_to :android_app_snapshot_job  
  has_many :android_app_snapshot_exceptions

  has_many :android_app_snapshots_screenshots, -> {order(position: :asc)}
  has_many :android_app_categories_snapshots
  has_many :android_app_categories, through: :android_app_categories_snapshots
  
  enum status: [:failure, :success]

  
end
