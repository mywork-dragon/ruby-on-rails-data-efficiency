# == Schema Information
#
# Table name: ios_sdk_update_exceptions
#
#  id                :integer          not null, primary key
#  sdk_name          :string(191)
#  ios_sdk_update_id :integer
#  error             :text(65535)
#  backtrace         :text(65535)
#  created_at        :datetime
#  updated_at        :datetime
#

class IosSdkUpdateException < ActiveRecord::Base

  belongs_to :ios_sdk_update
  
end
