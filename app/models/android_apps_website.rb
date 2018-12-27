# == Schema Information
#
# Table name: android_apps_websites
#
#  id             :integer          not null, primary key
#  android_app_id :integer
#  website_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class AndroidAppsWebsite < ActiveRecord::Base

  belongs_to :android_app
  belongs_to :website

end
