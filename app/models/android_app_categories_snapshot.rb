class AndroidAppCategoriesSnapshot < ActiveRecord::Base

  belongs_to :android_app_category
  belongs_to :android_app_snapshot

end
