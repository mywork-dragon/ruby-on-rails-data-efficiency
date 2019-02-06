# == Schema Information
#
# Table name: cocoapod_source_data
#
#  id          :integer          not null, primary key
#  name        :string(191)
#  cocoapod_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#  flagged     :boolean          default(FALSE)
#

class CocoapodSourceData < ActiveRecord::Base

	belongs_to :cocoapod

end
