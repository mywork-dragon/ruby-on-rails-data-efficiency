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

  has_many :tag_relationships, as: :taggable
  has_many :tags, through: :tag_relationships

  include DeveloperContactWebsites
  include MobileDeveloper

  def platform
    :ios
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
      platform: :ios,
      app_store_id: identifier
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
      publishers = DomainDataHotStore.new.read(domain)["publishers"]
      if publishers
        publishers.select {|x| x['platform'] == 'ios'}.map {|publisher| IosDeveloper.find_by_id(publisher['publisher_id'])}.compact
      else
        return []
      end
    end
  end
end
