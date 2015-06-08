class ListsUser < ActiveRecord::Base

  belongs_to :list
  belongs_to :user

  belongs_to :listable, polymorphic: true

end
