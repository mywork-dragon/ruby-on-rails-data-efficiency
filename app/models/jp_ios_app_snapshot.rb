class JpIosAppSnapshot < ActiveRecord::Base
  
  
  belongs_to :ios_app
  # belongs_to :ios_app_snapshot_job

  has_many :ios_app_snapshot_exceptions
  
  enum status: [:failure, :success]
  
  enum user_base: [:elite, :strong, :moderate, :weak]
  enum mobile_priority: [:high, :medium, :low]
  
end
