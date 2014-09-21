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
