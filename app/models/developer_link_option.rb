class DeveloperLinkOption < ActiveRecord::Base
  belongs_to :ios_developer
  belongs_to :android_developer

  enum method: [:name_match, :website_match]

  def investigate
    ap IosDeveloper.find(ios_developer_id)
    ap AndroidDeveloper.find(android_developer_id)
    puts "Linking Method --> #{methods.invert[method]}"
  end
end
