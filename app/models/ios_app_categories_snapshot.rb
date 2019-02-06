# == Schema Information
#
# Table name: ios_app_categories_snapshots
#
#  id                  :integer          not null, primary key
#  ios_app_category_id :integer
#  ios_app_snapshot_id :integer
#  kind                :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class IosAppCategoriesSnapshot < ActiveRecord::Base
  belongs_to :ios_app_category
  belongs_to :ios_app_snapshot
  enum kind: [:primary, :secondary]

  def as_json(_options = {})
    ios_app_category.as_json.merge(
      type: kind
    )
  end
end
