# == Schema Information
#
# Table name: ios_app_category_name_backups
#
#  id                  :integer          not null, primary key
#  name                :string(191)
#  app_store_id        :integer
#  ios_app_category_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class IosAppCategoryNameBackup < ActiveRecord::Base
  belongs_to :app_store
  belongs_to :ios_app_category
end
