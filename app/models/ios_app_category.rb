# == Schema Information
#
# Table name: ios_app_categories
#
#  id                  :integer          not null, primary key
#  name                :string(191)
#  created_at          :datetime
#  updated_at          :datetime
#  category_identifier :integer
#  is_ranking_label    :boolean          default(FALSE)
#  parent_identifier   :integer
#

class IosAppCategory < ActiveRecord::Base
  has_many :ios_app_categories_snapshots
  has_many :ios_app_snapshots, through: :ios_app_categories_snapshots

  has_many :ios_app_categories_current_snapshots
  has_many :ios_app_current_snapshots, through: :ios_app_categories_current_snapshots

  has_many :ios_app_categories_current_snapshot_backups
  has_many :ios_app_current_snapshot_backups, through: :ios_app_categories_current_snapshot_backups, source: :ios_app_current_snapshot_backup

  has_many :ios_app_category_names
  has_many :ios_app_category_name_backups

  has_many :app_stores, through: :ios_app_category_names

  def as_json(_options = {})
    {
      name: name,
      id: category_identifier,
      platform: 'ios'
    }
  end
end
