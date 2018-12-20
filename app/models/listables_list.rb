# == Schema Information
#
# Table name: listables_lists
#
#  id            :integer          not null, primary key
#  listable_id   :integer
#  list_id       :integer
#  listable_type :string(191)
#  created_at    :datetime
#  updated_at    :datetime
#

class ListablesList < ActiveRecord::Base
  
  belongs_to :listable, polymorphic: true
  belongs_to :list
  
end
