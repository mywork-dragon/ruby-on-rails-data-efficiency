# == Schema Information
#
# Table name: services
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  website    :string(191)
#  category   :string(191)
#  created_at :datetime
#  updated_at :datetime
#

class Service < ActiveRecord::Base
  has_many :matchers
  has_many :installations

  def possible_match?(content)
    content.include? name.downcase
  end

end
