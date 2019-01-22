# == Schema Information
#
# Table name: ios_app_category_names
#
#  id                  :integer          not null, primary key
#  name                :string(191)
#  app_store_id        :integer
#  ios_app_category_id :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class IosAppCategoryName < ActiveRecord::Base

  belongs_to :app_store
  belongs_to :ios_app_category

end
