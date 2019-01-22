# == Schema Information
#
# Table name: api_tokens
#
#  id          :integer          not null, primary key
#  account_id  :integer
#  token       :string(191)      not null
#  rate_window :integer          default(0)
#  rate_limit  :integer          default(2500)
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ApiToken < ActiveRecord::Base
  belongs_to :account

  enum rate_window: [:hourly, :daily, :monthly, :yearly]

  def period
    case ApiToken.rate_windows[rate_window]
    when 0
      1.hours
    when 1
      1.days
    when 2
      1.months
    when 3
      1.years
    else
      1.minutes
    end
  end
end
