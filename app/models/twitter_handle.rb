class TwitterHandle < ActiveRecord::Base
  has_many :owner_twitter_handles
end
