class Website < ActiveRecord::Base
  belongs_to :company
  
  has_many :ios_apps_websites
  has_many :ios_apps, through: :ios_apps_websites

  has_many :android_apps_websites
  has_many :android_apps, through: :android_apps_websites
  
  enum kind: [:primary, :secondary]
  
  validates :url, uniqueness: true

end
