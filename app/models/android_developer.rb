class AndroidDeveloper < ActiveRecord::Base

  belongs_to :company
  has_many :android_apps

  has_many :android_developers_websites
  has_many :websites, through: :android_developers_websites

  has_one :app_developers_developer, -> { where 'app_developers_developers.flagged' => false }, as: :developer
  has_one :app_developer, through: :app_developers_developer

  has_many :valid_android_developer_websites, -> { where(is_valid: true)}, class_name: 'AndroidDevelopersWebsite'
  has_many :valid_websites, through: :valid_android_developer_websites, source: :website

  has_many :tag_relationships, as: :taggable
  has_many :tags, through: :tag_relationships

  include DeveloperContactWebsites
  include MobileDeveloper

  def platform
    :android
  end

  def website_urls
    websites.map(&:url).uniq
  end

  def developer_info
    websites.map(&:domain_datum).uniq.compact
  end

  def developer_json
    {
      id: id,
      name: name,
      platform: :android,
      identifier: identifier
    }
  end

  def api_json(options = {})
    data = developer_json
    data[:details] = developer_info unless options[:short_form]
    data[:websites] = website_urls unless options[:short_form]
    data
  end

  class << self
    def find_by_domain(domain)
      AndroidDeveloper
        .joins(:websites)
        .where('websites.domain = ?', domain)
        .where('android_developers_websites.is_valid = ?', true).distinct
    end
  end
end
