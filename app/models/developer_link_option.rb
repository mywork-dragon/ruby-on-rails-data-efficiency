class DeveloperLinkOption < ActiveRecord::Base
  belongs_to :ios_developer
  belongs_to :android_developer

  enum method: [:name_match, :website_match]
end
