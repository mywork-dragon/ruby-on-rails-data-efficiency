class Service < ActiveRecord::Base
  has_many :matchers
  has_many :installation

  def possible_match?(content)
    content.include? name.downcase
  end

end
