class Website < ActiveRecord::Base
  belongs_to :company
  
  has_many :ios_apps_websites
  has_many :ios_apps, through: :ios_apps_websites
  
  enum kind: [:primary, :social]

end
