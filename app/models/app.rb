class App < ActiveRecord::Base

  belongs_to :company
  has_many :ios_apps
  has_many :android_apps
  
  
end
