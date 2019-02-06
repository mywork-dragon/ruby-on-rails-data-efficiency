# == Schema Information
#
# Table name: cocoapod_authors
#
#  id          :integer          not null, primary key
#  name        :string(191)
#  email       :text(65535)
#  cocoapod_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class CocoapodAuthor < ActiveRecord::Base

	belongs_to :cocoapod

end
