# == Schema Information
#
# Table name: ios_classification_frameworks
#
#  id         :integer          not null, primary key
#  name       :string(191)      not null
#  ios_sdk_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class IosClassificationFramework < ActiveRecord::Base
  belongs_to :ios_sdk
end
