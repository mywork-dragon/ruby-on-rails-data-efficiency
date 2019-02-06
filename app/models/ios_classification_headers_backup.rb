# == Schema Information
#
# Table name: ios_classification_headers_backups
#
#  id                :integer          not null, primary key
#  name              :string(191)
#  ios_sdk_id        :integer
#  is_unique         :boolean
#  collision_sdk_ids :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class IosClassificationHeadersBackup < ActiveRecord::Base
  serialize :collision_sdk_ids, Array
end
