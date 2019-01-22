# == Schema Information
#
# Table name: apple_docs
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  created_at :datetime
#  updated_at :datetime
#

class AppleDoc < ActiveRecord::Base
end
