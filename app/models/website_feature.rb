# == Schema Information
#
# Table name: website_features
#
#  id        :integer          not null, primary key
#  user_id   :integer
#  name      :integer
#  last_used :datetime
#

class WebsiteFeature < ActiveRecord::Base

  belongs_to :user
  enum name: [:timeline, :filtering, :live_scan, :ad_intelligence, :contacts, :ewok, :search]

end
