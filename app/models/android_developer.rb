# == Schema Information
#
# Table name: android_developers
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  identifier :string(191)
#  company_id :integer
#  created_at :datetime
#  updated_at :datetime
#

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
  
  def active_apps
    android_apps.normal.map{ |a| { id: a.id, bundle_id: a.app_identifier }}
  end

  def developer_info
    websites.map(&:domain_datum).uniq.compact
  end

  def ratings_all_count
    apps.limit(500).inject(0){|sum,app| sum + app.ratings_all_count.to_i}
  end

  def downloads_count
    apps.limit(500).inject(0){|sum,app| sum + app.downloads_min.to_i}
  end

  def ratings_score
    select_apps = apps.limit(500)
    if select_apps.any?
      return select_apps.inject(0){|sum,app| sum + app.newest_android_app_snapshot.try(:ratings_all_stars).to_f} / select_apps.size
    end

    nil
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
    data[:apps] = active_apps unless options[:short_form]
    data
  end

  def hotstore_json(options = {})
    {
      id: id,
      name: name,
      platform: :android,
      publisher_identifier: identifier,
      websites: website_urls,
      apps: android_apps.pluck(:id).map {|x| {"id" => x,"platform" => "android"}},
      contacts: ClearbitContact.joins(:website).where(websites: { domain: possible_contact_domains}).count
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
