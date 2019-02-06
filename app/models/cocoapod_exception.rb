# == Schema Information
#
# Table name: cocoapod_exceptions
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  cocoapod_id :integer
#  error       :text(65535)
#  backtrace   :text(65535)
#

class CocoapodException < ActiveRecord::Base
  belongs_to :cocoapod
end
