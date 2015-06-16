class ApiKey < ActiveRecord::Base

  has_many :accounts_api_keys
  has_many :accounts, through: :accounts_api_keys

end
