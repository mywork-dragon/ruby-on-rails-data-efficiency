# == Schema Information
#
# Table name: users_countries
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  country_code :string(191)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class UsersCountry < ActiveRecord::Base
  belongs_to :user
end
