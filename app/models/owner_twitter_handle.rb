# == Schema Information
#
# Table name: owner_twitter_handles
#
#  id                :integer          not null, primary key
#  twitter_handle_id :integer
#  owner_id          :integer
#  owner_type        :string(191)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class OwnerTwitterHandle < ActiveRecord::Base
  belongs_to :twitter_handle
  belongs_to :owner, polymorphic: true
end
