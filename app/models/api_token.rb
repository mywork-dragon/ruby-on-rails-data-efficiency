class ApiToken < ActiveRecord::Base
  belongs_to :account

  enum rate_window: [:hourly, :daily, :monthly]

end
