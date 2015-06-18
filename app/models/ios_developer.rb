class IosDeveloper < ActiveRecord::Base

  validates :identifier, uniqueness: true

  belongs_to :company
  has_many :ios_apps
  
  

end
