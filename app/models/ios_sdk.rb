class IosSdk < ActiveRecord::Base

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
  has_many :sdk_regexes
  has_many :sdk_string_regexes

  has_many :ios_sdk_source_matches, foreign_key: :source_sdk_id
  has_many :source_matches, through: :ios_sdk_source_matches, source: :match_sdk

  has_one :outbound_sdk_link, class_name: 'IosSdkLink', foreign_key: :source_sdk_id
  has_one :outbound_sdk, through: :outbound_sdk_link, source: :dest_sdk

  has_many :inbound_sdk_links, class_name: 'IosSdkLink', foreign_key: :dest_sdk_id
  has_many :inbound_sdks, through: :inbound_sdk_links, source: :source_sdk
  
  has_many :weekly_batches, as: :owner

  enum source: [:cocoapods, :package_lookup, :manual]

  enum kind: [:native, :js]
  validates :kind, presence: true

  def get_current_apps(limit = nil, sort = nil, with_associated: true)

    apps = IosSdk.get_current_apps_with_sdks(ios_sdk_ids: [self.id], with_associated: with_associated)

    apps = apps.order("#{sort} ASC") if sort
    apps = apps.limit(limit) if limit
    apps

  end

  def platform
    'ios'
  end

  def cluster
    IosSdk.sdk_clusters(ios_sdk_ids: [self.id])
  end

  class << self

    def display_sdks
      IosSdk.joins('LEFT JOIN ios_sdk_links ON ios_sdk_links.source_sdk_id = ios_sdks.id').where('dest_sdk_id is NULL')
    end

    def sdk_clusters(ios_sdk_ids:)

      dest_sdk_ids = IosSdk.joins('left join ios_sdk_links on ios_sdks.id = ios_sdk_links.source_sdk_id').select('IFNULL(dest_sdk_id, ios_sdks.id) as id').where(id: ios_sdk_ids).to_a

      dest_sdk_ids.map! { |x| x.id }.uniq

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
      IosSdk.create!({
        name: name,
        website: website,
        favicon: favicon || FaviconService.get_favicon_from_url(url: website),
        open_source: open_source || /(?:bitbucket|github|sourceforge)/.match(website),
        summary: summary,
        github_repo_identifier: github_repo_identifier,
        source: :manual,
        kind: kind
        })
    end
  end

end
