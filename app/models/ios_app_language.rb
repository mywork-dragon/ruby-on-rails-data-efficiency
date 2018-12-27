# == Schema Information
#
# Table name: ios_app_languages
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name       :string(191)
#

class IosAppLanguage < ActiveRecord::Base

  has_many :ios_app_snapshots_languages
  has_many :ios_app_snapshots, through: :ios_app_snapshots_languages
  
  has_many :android_app_releases

end
