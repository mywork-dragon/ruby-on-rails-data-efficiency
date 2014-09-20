class Service < ActiveRecord::Base
  has_many :matchers
  has_many :installation
  
end
