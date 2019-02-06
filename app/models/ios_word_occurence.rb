# == Schema Information
#
# Table name: ios_word_occurences
#
#  id         :integer          not null, primary key
#  word       :string(191)
#  count      :integer
#  created_at :datetime
#  updated_at :datetime
#

class IosWordOccurence < ActiveRecord::Base
end
