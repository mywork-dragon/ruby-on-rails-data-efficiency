class OwnerTwitterHandle < ActiveRecord::Base
  belongs_to :twitter_handle
  belongs_to :owner, polymorphic: true
end
