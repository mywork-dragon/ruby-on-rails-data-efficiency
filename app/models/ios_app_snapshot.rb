class IosAppSnapshot < ActiveRecord::Base

  has_many :ios_app_snapshots_languages
  has_many :ios_app_languages, through: :ios_app_snapshots_languages
  
  belongs_to :ios_app
  belongs_to :ios_app_snapshot_job
  has_many :ios_app_categories_snapshots
  has_many :ios_app_categories, through: :ios_app_categories_snapshots

  has_many :ios_app_snapshot_exceptions
  
  enum status: [:failure, :success]

  searchable do
    text :name, :seller_url
  end
    
end
