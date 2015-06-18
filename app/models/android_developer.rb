class AndroidDeveloper < ActiveRecord::Base
  
  belongs_to :company
  has_many :android_apps
  
  
end
