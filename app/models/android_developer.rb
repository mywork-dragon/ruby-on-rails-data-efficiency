class AndroidDeveloper < ActiveRecord::Base
  
  validates :identifier, uniqueness: true
  
  belongs_to :company
  has_many :android_apps
  
  
end
