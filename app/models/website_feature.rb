class WebsiteFeature < ActiveRecord::Base

  belongs_to :user
  enum name: [:timeline, :filtering, :live_scan, :ad_intelligence, :contacts, :ewok, :search]

end
