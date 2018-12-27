# == Schema Information
#
# Table name: matchers
#
#  id           :integer          not null, primary key
#  service_id   :integer
#  match_type   :integer
#  match_string :text(65535)
#  created_at   :datetime
#  updated_at   :datetime
#

class Matcher < ActiveRecord::Base
  belongs_to :service
  enum match_type: [:regex, :string]

  def match?(content)
    if regex?
      content =~ Regexp.new(match_string)
    elsif string?
      content.include?(match_string)
    end
  end

end
