# == Schema Information
#
# Table name: developer_link_options
#
#  id                   :integer          not null, primary key
#  ios_developer_id     :integer
#  android_developer_id :integer
#  method               :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class DeveloperLinkOption < ActiveRecord::Base
  belongs_to :ios_developer
  belongs_to :android_developer

  enum method: [:name_match, :website_match]

  def investigate
    ap IosDeveloper.find(ios_developer_id)
    ap AndroidDeveloper.find(android_developer_id)
    puts "Linking Method --> #{method}"
  end
end
