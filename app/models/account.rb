class Account < ActiveRecord::Base
  
  has_many :users
  
  has_many :accounts_api_keys
  has_many :api_keys, through: :accounts_api_keys
  
end
