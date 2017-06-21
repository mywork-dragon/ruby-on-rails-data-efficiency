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
