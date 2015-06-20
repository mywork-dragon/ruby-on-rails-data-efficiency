class AccountsApiKey < ActiveRecord::Base

  belongs_to :account
  belongs_to :api_key
  
end
