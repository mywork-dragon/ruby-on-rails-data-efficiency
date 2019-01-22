# == Schema Information
#
# Table name: cocoapods
#
#  id           :integer          not null, primary key
#  version      :string(191)
#  git          :text(65535)
#  http         :text(65535)
#  tag          :string(191)
#  created_at   :datetime
#  updated_at   :datetime
#  ios_sdk_id   :integer
#  json_content :text(65535)
#

class Cocoapod < ActiveRecord::Base
	belongs_to :ios_sdk
	has_many :cocoapod_source_datas
  has_many :cocoapod_exceptions
end
