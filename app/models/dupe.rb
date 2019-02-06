# == Schema Information
#
# Table name: dupes
#
#  id             :integer          not null, primary key
#  app_identifier :string(191)
#  created_at     :datetime
#  updated_at     :datetime
#  count          :integer
#

class Dupe < ActiveRecord::Base
end
