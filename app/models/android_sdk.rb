# == Schema Information
#
# Table name: android_sdks
#
#  id                     :integer          not null, primary key
#  name                   :string(191)
#  website                :string(191)
#  favicon                :string(191)
#  flagged                :boolean          default(FALSE)
#  open_source            :boolean
#  created_at             :datetime
#  updated_at             :datetime
#  sdk_company_id         :integer
#  github_repo_identifier :integer
#  kind                   :integer
#  summary                :text(65535)
#

class AndroidSdk < ActiveRecord::Base
  include Sdk

	belongs_to :sdk_company
  has_many :sdk_packages

  has_many :android_sdks_apk_snapshots
  has_many :apk_snapshots, through: :android_sdks_apk_snapshots

  has_many :tags, through: :tag_relationships
  has_many :tag_relationships, as: :taggable

  has_many :weekly_batches, as: :owner

  has_one :outbound_sdk_link, class_name: 'AndroidSdkLink', foreign_key: :source_sdk_id
  has_one :outbound_sdk, through: :outbound_sdk_link, source: :dest_sdk

  has_many :inbound_sdk_links, class_name: 'AndroidSdkLink', foreign_key: :dest_sdk_id
  has_many :inbound_sdks, through: :inbound_sdk_links, source: :source_sdk

  has_one :outbound_sdk_link, class_name: 'AndroidSdkLink', foreign_key: :source_sdk_id
  has_one :outbound_sdk, through: :outbound_sdk_link, source: :dest_sdk

  has_many :inbound_sdk_links, class_name: 'AndroidSdkLink', foreign_key: :dest_sdk_id
  has_many :inbound_sdks, through: :inbound_sdk_links, source: :source_sdk

  has_many :owner_twitter_handles, as: :owner
  has_many :twitter_handles, through: :owner_twitter_handles

  enum kind: [:native, :js]

  validates :kind, presence: true

  update_index('android_sdk#android_sdk') { self if AndroidSdk.display_sdks.where(flagged: false).find_by_id(self.id) } if Rails.env.production?

  attr_accessor :first_seen
  attr_accessor :last_seen
  attr_writer :es_client

  def self.app_class
    AndroidApp
  end

  def es_client
    @es_client ||= AppsIndex::AndroidApp
    @es_client
  end

  def get_favicon
    if self.website.present?
      host = URI(self.website).host
      "https://www.google.com/s2/favicons?domain=#{host}"
    else
      self.favicon
    end
  end

  def get_current_apps(limit: nil, sort: nil, order: 'desc', with_associated: true, app_ids: nil)

    filter_args = {
      app_filters: {"sdkFiltersAnd" => [{"id" => id, "status" => "0", "date" => "0"}]},
      page_num: 1,
      order_by: order
    }

    filter_args[:app_filters]['appIds'] = app_ids if app_ids
    filter_args[:page_size] = limit if limit
    filter_args[:sort_by] = sort if sort

    filter_results = FilterService.filter_android_apps(filter_args)
    ids = filter_results.map { |result| result.attributes["id"] }
    apps = if ids.any?
      collection = AndroidApp.where(id: ids)
      collection = collection.order("FIELD(id, #{ids.join(',')})") if sort
      collection
    else
      []
    end

    {apps: apps, total_count: filter_results.total_count}
  end

  def test
    snaps = self.apk_snapshots.select(:id).map(&:id)
    AndroidApp.where(newest_apk_snapshot_id: snaps).count
  end

  # Debug method, not safe for prod since it uses map
  # @author Jason Lew
  def android_apps
    apk_snapshots.map(&:android_app)
  end

  def as_json(options={})
    batch_json = {
      id: self.id,
      type: self.class.name,
      platform: :android,
      name: self.name,
      icon: self.get_favicon,
      website: self.website,
      openSource: self.open_source,
      tags: self.tags
    }
    batch_json[:following] = options[:user].following?(self) if options[:user]
    if options[:account]
      batch_json[:following] = options[:account].following?(self)
    end

    batch_json
  end

  def cluster
    AndroidSdk.sdk_clusters(android_sdk_ids: [self.id])
  end

  # API methods
  def api_apps_count
    es_client.query(
      terms: {
        'installed_sdks.id' => [id]
      }
    ).total_count
  end

  def api_json(options = {})
    include_keys = if options[:short_form]
                     [:id, :name]
                   else
                     [:id, :name, :platform, :website]
                   end
    res = as_json.select { |k| include_keys.include?(k) }
    res[:categories] = tags.pluck(:name)
    res[:apps_count] = api_apps_count unless options[:short_form]
    res
  end

  class << self

    def display_sdks
      AndroidSdk
        .joins('LEFT JOIN android_sdk_links ON android_sdk_links.source_sdk_id = android_sdks.id')
        .where('dest_sdk_id is NULL')
    end

    def sdk_clusters(android_sdk_ids:)

      dest_sdk_ids = AndroidSdk
        .joins('left join android_sdk_links on android_sdks.id = android_sdk_links.source_sdk_id')
        .select('IFNULL(dest_sdk_id, android_sdks.id) as id').where(id: android_sdk_ids).to_a

      dest_sdk_ids = dest_sdk_ids.map(&:id).uniq

      inbound_sdk_ids = AndroidSdk.joins(:outbound_sdk).where('android_sdk_links.dest_sdk_id in (?)', dest_sdk_ids)

      AndroidSdk.where(id: inbound_sdk_ids + dest_sdk_ids)
    end

    # @note with_associated: Whether to use clusters
    def get_current_apps_with_sdks(android_sdk_ids:, with_associated: true)
      cluster_ids = if with_associated
        sdk_clusters(android_sdk_ids: android_sdk_ids).pluck(:id)
      else
        android_sdk_ids
      end

      AndroidApp.distinct.joins(:newest_apk_snapshot).joins('inner join android_sdks_apk_snapshots on apk_snapshots.id = android_sdks_apk_snapshots.apk_snapshot_id').where('android_sdks_apk_snapshots.android_sdk_id in (?)', cluster_ids)
    end
  end

end
