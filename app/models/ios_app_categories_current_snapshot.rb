# == Schema Information
#
# Table name: ios_app_categories_current_snapshots
#
#  id                          :integer          not null, primary key
#  ios_app_category_id         :integer
#  ios_app_current_snapshot_id :integer
#  kind                        :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#

class IosAppCategoriesCurrentSnapshot < ActiveRecord::Base

  belongs_to :ios_app_current_snapshot
  belongs_to :ios_app_category

  enum kind: [:primary, :secondary]

  def as_json(_options = {})
    ios_app_category.as_json.merge(
      type: kind
    )
  end

end
