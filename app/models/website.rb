class Website < ActiveRecord::Base
  belongs_to :company
  
  has_many :ios_app_websites
  has_many :ios_apps, through: :ios_app_websites
  
  enum :kind [:primary, :social]

end
