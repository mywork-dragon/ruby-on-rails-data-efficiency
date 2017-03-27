class ChallengeController < ApplicationController

  layout "marketing"

  def payment_seed
    render json: fake_payments
  end

  # produce one roughly every other day. amounts vary but should generally skew towards getting larger
  def fake_payments(count: 100)
    payment_days = (1..(count * 2)).to_a.shuffle.take(count).sort
    count.times.map do |i|
      amount = (rand * i + 0.01).round(2)
      {
        name: Faker::Company.name,
        amount: amount,
        date: payment_days.pop.days.ago.to_date
      }
    end
  end
end
