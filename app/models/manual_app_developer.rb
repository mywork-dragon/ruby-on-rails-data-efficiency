# == Schema Information
#
# Table name: manual_app_developers
#
#  id                    :integer          not null, primary key
#  name                  :string(191)
#  ios_developer_ids     :text(65535)
#  android_developer_ids :text(65535)
#  flagged               :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class ManualAppDeveloper < ActiveRecord::Base
  serialize :ios_developer_ids, Array
  serialize :android_developer_ids, Array
end
