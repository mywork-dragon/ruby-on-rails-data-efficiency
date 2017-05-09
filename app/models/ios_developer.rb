class IosDeveloper < ActiveRecord::Base

  belongs_to :company
  has_many :ios_apps
  
  has_many :ios_developers_websites
  has_many :websites, through: :ios_developers_websites

  has_many :valid_ios_developer_websites, -> { where(is_valid: true)}, class_name: 'IosDevelopersWebsite'
  has_many :valid_websites, through: :valid_ios_developer_websites, source: :website

  has_one :app_developers_developer, -> { where 'app_developers_developers.flagged' => false }, as: :developer
  has_one :app_developer, through: :app_developers_developer

  has_many :developer_link_options

  include DeveloperContactWebsites
  include MobileDeveloper

  def platform
    'ios'
  end
end
