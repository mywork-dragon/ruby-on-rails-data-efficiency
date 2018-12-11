# == Schema Information
#
# Table name: android_sdk_companies_android_apps
#
#  id                     :integer          not null, primary key
#  android_sdk_company_id :integer
#  android_app_id         :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class AndroidSdkCompaniesAndroidApp < ActiveRecord::Base

  belongs_to :android_sdk_company
  belongs_to :android_app

end
