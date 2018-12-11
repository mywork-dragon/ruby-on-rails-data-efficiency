# == Schema Information
#
# Table name: app_developers_developers
#
#  id               :integer          not null, primary key
#  app_developer_id :integer
#  developer_id     :integer
#  developer_type   :string(191)
#  method           :integer
#  flagged          :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class AppDevelopersDeveloper < ActiveRecord::Base
  belongs_to :app_developer
  belongs_to :developer, polymorphic: true
end
