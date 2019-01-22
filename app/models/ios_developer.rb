# == Schema Information
#
# Table name: ios_developers
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  identifier :integer
#  company_id :integer
#  created_at :datetime
#  updated_at :datetime
#

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

  def ratings_all_count
    apps.limit(500).inject(0){|sum,app| sum + app.total_rating_count.to_i}
  end

  def ratings_score
    select_apps = apps.limit(500)
    if select_apps.any?
      return select_apps.inject(0){|sum,app| sum + app.rating[:rating].to_f} / select_apps.size
    end

    nil
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

  def ios_apps
    super.where.not(:display_type => IosApp.display_types['not_ios'])
  end

  def hotstore_json(options = {})
    {
      id: id,
      name: name,
      platform: :ios,
      publisher_identifier: identifier,
      websites: website_urls,
      apps: ios_apps.pluck(:id).map {|x| {"id" => x,"platform" => "ios"}}
    }
  end

  class << self
    def find_by_domain(domain)
      domain = UrlHelper.url_with_domain_only(domain)
      publishers = DomainDataHotStore.new.read(domain)["publishers"]
      if publishers
        publishers.select {|x| x['platform'] == 'ios'}.map {|publisher| IosDeveloper.find_by_id(publisher['publisher_id'])}.compact
      else
        return []
      end
    end
  end
end
