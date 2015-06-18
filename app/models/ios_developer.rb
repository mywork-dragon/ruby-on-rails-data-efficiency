class IosDeveloper < ActiveRecord::Base

  has_many :companies_ios_developers
  has_many :ios_developers, through: :companies_ios_developers
  
end
