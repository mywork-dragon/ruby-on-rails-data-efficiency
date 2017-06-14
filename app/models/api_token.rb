class ApiToken < ActiveRecord::Base
  belongs_to :account

  enum rate_window: [:hourly, :daily, :monthly]

  def period
    case ApiToken.rate_windows[rate_window]
    when 0
      1.hours
    when 1
      1.days
    when 2
      1.months
    else
      1.minutes
    end
  end
end
