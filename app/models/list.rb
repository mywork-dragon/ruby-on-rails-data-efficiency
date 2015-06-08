class List < ActiveRecord::Base

  has_many :lists_users
  has_many :users, through: :lists_users

  belongs_to :listable, polymorphic: true

end
