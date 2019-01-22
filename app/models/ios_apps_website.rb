# == Schema Information
#
# Table name: ios_apps_websites
#
#  id         :integer          not null, primary key
#  ios_app_id :integer
#  website_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class IosAppsWebsite < ActiveRecord::Base
  belongs_to :ios_app
  belongs_to :website
  
end
