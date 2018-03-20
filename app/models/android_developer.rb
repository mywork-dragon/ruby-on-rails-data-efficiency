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

  def hotstore_json(options = {})
    {
      id: id,
      name: name,
      platform: :android,
      publisher_identifier: identifier,
      websites: website_urls,
      apps: android_apps.pluck(:id).map {|x| {"id" => x,"platform" => "android"}}
    }
  end

  class << self
    def find_by_domain(domain)
      domain = UrlHelper.url_with_domain_only(domain)
      publishers = DomainDataHotStore.new.read(domain)["publishers"]
      if publishers
        publishers.select {|x| x['platform'] == 'android'}.map {|publisher| AndroidDeveloper.find_by_id(publisher['publisher_id'])}.compact
      else
        return []
      end
    end
  end
end
