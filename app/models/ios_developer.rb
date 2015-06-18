class IosDeveloper < ActiveRecord::Base

  belongs_to :company
  has_many :ios_apps

end
