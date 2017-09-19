class IosSdk < ActiveRecord::Base
  include Sdk

  has_many :owner_twitter_handles, as: :owner
  has_many :twitter_handles, through: :owner_twitter_handles

	belongs_to :sdk_company
  belongs_to :ios_sdk_source_group

  has_many :sdk_packages
  has_many :cocoapod_metrics

	has_many :ios_sdks_ipa_snapshots
  has_many :ipa_snapshots, through: :ios_sdks_ipa_snapshots

  has_many :cocoapods
  has_many :cocoapod_source_datas, through: :cocoapods

  has_many :ios_sdk_source_datas

  has_many :dll_regexes
  has_many :js_tag_regexes
  has_many :sdk_file_regexes
  has_many :header_regexes
  has_many :sdk_regexes   # packages
  has_many :sdk_string_regexes

  has_many :ios_sdk_source_matches, foreign_key: :source_sdk_id
  has_many :source_matches, through: :ios_sdk_source_matches, source: :match_sdk

  has_one :outbound_sdk_link, class_name: 'IosSdkLink', foreign_key: :source_sdk_id
  has_one :outbound_sdk, through: :outbound_sdk_link, source: :dest_sdk

  has_many :inbound_sdk_links, class_name: 'IosSdkLink', foreign_key: :dest_sdk_id
  has_many :inbound_sdks, through: :inbound_sdk_links, source: :source_sdk

  has_many :weekly_batches, as: :owner
  has_many :tags, through: :tag_relationships
  has_many :tag_relationships, as: :taggable

  has_many :owner_twitter_handles, as: :owner
  has_many :twitter_handles, through: :owner_twitter_handles

  enum source: [:cocoapods, :package_lookup, :manual]

  enum kind: [:native, :js]
  validates :kind, presence: true

  update_index('ios_sdk#ios_sdk') { self if IosSdk.display_sdks.where(flagged: false).find_by_id(self.id) } if Rails.env.production?

  attr_writer :es_client

  def self.app_class
    IosApp
  end

  def es_client
    @es_client ||= AppsIndex::IosApp
    @es_client
  end

  def get_current_apps(limit: nil, sort: nil, order: 'desc', with_associated: true, app_ids: nil)
    sdk_id = IosSdk.select('IFNULL(ios_sdk_links.dest_sdk_id, ios_sdks.id) as id').
                   joins('LEFT JOIN ios_sdk_links ON ios_sdk_links.source_sdk_id = ios_sdks.id').
                   where(id: id).first.id

    filter_args = {
      app_filters: {"sdkFiltersAnd" => [{"id" => sdk_id, "status" => "0", "date" => "0"}]},
      page_num: 1,
      order_by: order
    }

    filter_args[:app_filters]['appIds'] = app_ids if app_ids
    filter_args[:page_size] = limit if limit
    filter_args[:sort_by] = sort if sort

    filter_results = FilterService.filter_ios_apps(filter_args)
    ids = filter_results.map { |result| result.attributes["id"] }
    apps = if ids.any?
      collection = IosApp.where(id: ids)
      collection = collection.order("FIELD(id, #{ids.join(',')})") if sort
      collection
    else
      []
    end

    {apps: apps, total_count: filter_results.total_count}
  end

  def cluster
    IosSdk.sdk_clusters(ios_sdk_ids: [self.id])
  end

  def as_json(options={})
    batch_json = {
      id: self.id,
      type: self.class.name,
      platform: :ios,
      name: self.name,
      icon: self.favicon,
      openSource: self.open_source,
      website: self.website,
      summary: self.summary,
      tags: self.tags
    }
    batch_json[:following] = options[:user].following?(self) if options[:user]
    if options[:account]
      batch_json[:following] = options[:account].following?(self)
    end
    batch_json
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
      IosSdk.joins('LEFT JOIN ios_sdk_links ON ios_sdk_links.source_sdk_id = ios_sdks.id').where('dest_sdk_id is NULL')
    end

    def sdk_clusters(ios_sdk_ids:)

      dest_sdk_ids = IosSdk.joins('left join ios_sdk_links on ios_sdks.id = ios_sdk_links.source_sdk_id').select('IFNULL(dest_sdk_id, ios_sdks.id) as id').where(id: ios_sdk_ids).to_a

      dest_sdk_ids = dest_sdk_ids.map(&:id).uniq

      inbound_sdk_ids = IosSdk.joins(:outbound_sdk).where('ios_sdk_links.dest_sdk_id in (?)', dest_sdk_ids)

      IosSdk.where(id: inbound_sdk_ids + dest_sdk_ids)
    end

    def get_current_apps_with_sdks(ios_sdk_ids:, with_associated: true)

      cluster_ids = if with_associated
        sdk_clusters(ios_sdk_ids: ios_sdk_ids).pluck(:id)
      else
        ios_sdk_ids
      end

      IosApp.distinct.joins(:newest_ipa_snapshot).joins('inner join ios_sdks_ipa_snapshots on ipa_snapshots.id = ios_sdks_ipa_snapshots.ipa_snapshot_id').where('ios_sdks_ipa_snapshots.ios_sdk_id in (?)', cluster_ids)
    end

    def create_manual(name:, website:, kind:, favicon: nil, open_source: nil, summary: nil, github_repo_identifier: nil)
      attributes = {
          website: website,
          favicon: favicon || FaviconService.get_favicon_from_url(url: website),
          open_source: open_source || !!/(?:bitbucket|github|sourceforge)/.match(website),
          summary: summary,
          github_repo_identifier: github_repo_identifier,
          kind: kind
      }
      existing = IosSdk.find_by_name(name)
      if existing
        existing.update!(attributes)
        existing
      else
        attributes.merge!({name: name, source: :manual})
        IosSdk.create!(attributes)
      end
    end

    def csv_dump
      display_ids = IosSdk.display_sdks.pluck(:id)
      rows = IosSdk.select(:id, :name, :website, 'tags.name')
        .joins('left join tag_relationships on tag_relationships.taggable_id = ios_sdks.id AND tag_relationships.taggable_type = "IosSdk" left join tags on tags.id = tag_relationships.tag_id')
        .where(id: display_ids)
        .pluck(:id, :name, :website, 'tags.name')

      csv_string = CSV.generate do |csv|
        csv << ['id', 'name', 'website', 'tag_name', 'apps_count']
        rows.each do |row|
          id = row.first
          apps_count = 0
          begin
            res = MightyApi.ios_sdk_info(id)
            apps_count = res['apps_count'] || 0
          rescue MightyApi::FailedRequest => e
            puts e.message
            puts e.backtrace
          end
          csv << (row + [apps_count])
        end
      end

      MightyAws::S3.new.store(
        bucket: 'ms-misc',
        key_path: 'ios_sdk_dump.csv.gz',
        data_str: csv_string
      )
    end

    def sync_manual_data(model)
      model.each do |name, info|
        sdk = IosSdk.find_by_name(name)
        if sdk.nil?
          sdk = IosSdk.create_manual(
            name: name,
            website: info['website'],
            kind: :native,
            summary: info['summary']
          )
        end
        sdk.cocoapod_source_datas.where(flagged: false).update_all(flagged: true) # no longer use cocoapods info
        existing = sdk.ios_sdk_source_datas.pluck(:name)
        current = info['classes']
        to_remove = existing - current
        IosSdkSourceData.where(name: to_remove, ios_sdk_id: sdk.id).delete_all if to_remove.present?
        to_add = (current - existing).map {|n| IosSdkSourceData.new(ios_sdk_id: sdk.id, name: n)}
        IosSdkSourceData.import(to_add) if to_add.present?
      end
    end
  end
end
