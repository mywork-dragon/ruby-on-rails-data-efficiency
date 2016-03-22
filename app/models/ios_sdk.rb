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

  # TODO: currently returns taken down. Maybe revisit and fix later

  # this is the mysql version of the query (2362 is parse...substitute)
  # 
  # select distinct ios_apps.*
  # from ios_apps
  # join ipa_snapshots i1 on (i1.ios_app_id = ios_apps.id and i1.success = true and i1.scan_status = 1)
  # join (select max(good_as_of_date) as good_as_of_date, ios_app_id from ipa_snapshots where ipa_snapshots.success = true and ipa_snapshots.scan_status = 1 group by ios_app_id) i2 on i1.ios_app_id = i2.ios_app_id and i1.good_as_of_date = i2.good_as_of_date
  # join ios_sdks_ipa_snapshots on (i1.id = ios_sdks_ipa_snapshots.ipa_snapshot_id)
  # where (ios_sdks_ipa_snapshots.ios_sdk_id = 2362)
  
  def get_current_apps(limit=nil, sort=nil)
    # TODO: revisit this to make it 1 query
    apps = IosApp.where(id: self.ipa_snapshots.select('ios_app_id, max(good_as_of_date) as good_as_of_date').where(scan_status: 1).group(:ios_app_id).pluck(:ios_app_id))
    apps = apps.order("#{sort} ASC") if sort
    apps = apps.limit(limit) if limit
    apps
  end

  def platform
    'ios'
  end

  class << self
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
