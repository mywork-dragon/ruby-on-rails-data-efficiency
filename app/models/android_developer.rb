class AndroidDeveloper < ActiveRecord::Base

  has_many :companies_android_developers
  has_many :android_developers, through: :companies_android_developers

end
