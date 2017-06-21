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
