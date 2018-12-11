# == Schema Information
#
# Table name: lists_users
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  list_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ListsUser < ActiveRecord::Base

  belongs_to :list
  belongs_to :user

  belongs_to :listable, polymorphic: true

end
