class IosAppSnapshot < ActiveRecord::Base

  has_many :languages
  belongs_to :ios_app
  belongs_to :ios_app_snapshot_job
  has_many :ios_app_categories, through: :ios_app_categories_snapshots
  
end
