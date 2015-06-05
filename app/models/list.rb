class List < ActiveRecord::Base

  has_and_belongs_to_many :users
  belongs_to :listable, :polymorphic => true

end
