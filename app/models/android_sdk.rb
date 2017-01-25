class AndroidSdk < ActiveRecord::Base

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

  update_index('android_sdk#android_sdk') { self if IosSdk.display_sdks.where(flagged: false).find_by_id(self.id) } if Rails.env.production?

  attr_accessor :first_seen
  attr_accessor :last_seen

  def get_favicon
    if self.website.present?
      host = URI(self.website).host
      "https://www.google.com/s2/favicons?domain=#{host}"
    else
      self.favicon
    end
  end

  def get_current_apps(limit=nil, sort=nil, with_associated: true)
    apps = AndroidSdk.get_current_apps_with_sdks(android_sdk_ids: [self.id], with_associated: with_associated)

    apps = apps.order("#{sort} ASC") if sort
    apps = apps.limit(limit) if limit
    
    apps
  end

  def self.top_200_tags #tags that have android sdks in the top 200
    sdks = AndroidSdk.joins(:tags).uniq.to_a.reject {|sdk| sdk.top_200_apps.size == 0}.sort_by {|a| a.top_200_apps.size}.reverse
    Tag.joins(:tag_relationships).where('tag_relationships.taggable_id' => sdks.map{|sdk| sdk.id}, 
                                        'tag_relationships.taggable_type' => 'AndroidSdk').uniq
  end

  def top_200_apps
    newest_snapshot = AndroidAppRankingSnapshot.last_valid_snapshot
    self.get_current_apps.joins(:android_app_rankings).where(android_app_rankings: {android_app_ranking_snapshot_id: newest_snapshot.id}).
                          where('rank < 201').select(:rank, 'android_apps.*').order('rank ASC')
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
      platform: 'android',
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

  class << self

  def display_sdks
    AndroidSdk.joins('LEFT JOIN android_sdk_links ON android_sdk_links.source_sdk_id = android_sdks.id').where('dest_sdk_id is NULL')
  end

  def sdk_clusters(android_sdk_ids:)

    dest_sdk_ids = AndroidSdk.joins('left join android_sdk_links on android_sdks.id = android_sdk_links.source_sdk_id').select('IFNULL(dest_sdk_id, android_sdks.id) as id').where(id: android_sdk_ids).to_a

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

  def store_current_sdks_in_s3
    model_file = "db/android_class_model/model.json"
    m = JSON.parse(File::open(model_file).read())
    sdk_names = m['sdk_to_website'].keys().map {|x| x.downcase}
    csv_string = CSV.generate do |csv|
      csv << ['id', 'name', 'website', 'tag_name', 'apps_count']
      AndroidSdk.pluck(:id).map do |sdk_id|
        sdk = AndroidSdk.find(sdk_id)
        count = sdk.get_current_apps.count
        if sdk_names.include? sdk.name.downcase
          csv << [sdk.id, sdk.name, sdk.website, sdk.tags.first.try(:name), count]
        end
      end
    end

    MightyAws::S3.new.store(
      bucket: 'ms-misc',
      key_path: 'current_android_sdks_dump.csv.gz',
      data_str: csv_string
    )
  end

  end

end
