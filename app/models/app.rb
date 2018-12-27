# == Schema Information
#
# Table name: apps
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  company_id :integer
#  name       :string(191)
#

class App < ActiveRecord::Base

  belongs_to :company
  has_many :ios_apps
  has_many :android_apps
  
  
end
