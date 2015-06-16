class AccountsApiKey < ActiveRecord::Base

  belongs_to :account_id
  belongs_to :api_key
  
end
