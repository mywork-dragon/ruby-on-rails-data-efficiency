# == Schema Information
#
# Table name: cocoapod_tags
#
#  id          :integer          not null, primary key
#  tag         :string(191)
#  cocoapod_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class CocoapodTag < ActiveRecord::Base

	belongs_to :cocoapod

end
