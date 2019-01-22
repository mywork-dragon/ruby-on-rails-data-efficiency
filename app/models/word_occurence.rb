# == Schema Information
#
# Table name: word_occurences
#
#  id         :integer          not null, primary key
#  word       :string(191)
#  good       :integer
#  bad        :integer
#  created_at :datetime
#  updated_at :datetime
#

class WordOccurence < ActiveRecord::Base
end
