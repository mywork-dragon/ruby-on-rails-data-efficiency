class AndroidApp < ActiveRecord::Base
  include AppAds

  validates :app_identifier, uniqueness: true
  validate :validate_regions
  belongs_to :app

  has_many :listables_lists, as: :listable
  has_many :lists, through: :listables_lists

  has_many :android_fb_ad_appearances

  has_many :android_app_snapshots
  # has_many :websites, through: :android_apps_snapshots
  has_many :android_apps_websites
  has_many :websites, through: :android_apps_websites

  has_many :android_sdk_companies_android_apps
  has_many :android_sdk_companies, through: :android_sdk_companies_android_apps

  has_many :apk_snapshots

  belongs_to :newest_android_app_snapshot, class_name: 'AndroidAppSnapshot', foreign_key: 'newest_android_app_snapshot_id'
  belongs_to :newest_apk_snapshot, class_name: 'ApkSnapshot', foreign_key: 'newest_apk_snapshot_id'
  # after_update :set_user_base, if: :newest_android_app_snapshot_id_changed?

  belongs_to :android_developer
  has_many :android_app_rankings

  has_many :sdk_js_tags

  has_many :apk_snapshot_scrape_failures
  has_many :apk_snapshot_jobs
  has_many :apk_snapshot_scrape_exceptions
  has_many :weekly_batches, as: :owner
  has_many :follow_relationships
  has_many :followers, as: :followable, through: :follow_relationships

  enum mobile_priority: [:high, :medium, :low]
  enum user_base: [:elite, :strong, :moderate, :weak]

  enum display_type: [:normal, :taken_down, :foreign, :paid]

  serialize :regions, JSON

  has_many :android_ads, :foreign_key => :advertised_app_id

  ad_table :android_ads
  # update_index('apps#android_app') { self } if Rails.env.production?

  def validate_regions
    available_regions = [nil] + MicroProxy.regions.values
    if (regions.select {|x| not available_regions.include? x}).size > 0
      errors.add(:regions, :invalid)
    end
  end

  def international?
     (regions - [nil, MicroProxy.regions["US"]]).count > 0
  end

  def add_region(region)
    region = MicroProxy.regions[region]
    if not regions.include? region
      self.regions += [region]
    end
  end

  def region_codes
    regions.map {|x| MicroProxy.regions.key(x)}
  end

  def get_newest_app_snapshot
    self.android_app_snapshots.max_by do |snapshot|
      snapshot.created_at
    end
  end

  def get_website_urls
    websites.map{|w| w.url}
  end

  def get_company
    self.websites.each do |w|
      if w.company.present?
        return w.company
      end
    end
    return nil
  end

  def fortune_rank
    self.android_developer.try(:fortune_1000_rank)
  end

  def name
    if newest_android_app_snapshot.present?
      return newest_android_app_snapshot.name
    else
      return nil
    end
  end

  def top_200_rank
    self.android_app_rankings.last.rank
  end

  def is_in_top_200?
    newest_rank_snapshot = AndroidAppRankingSnapshot.last_valid_snapshot
    return false unless newest_rank_snapshot
    newest_rank_snapshot.android_app_rankings.where(android_app_id: self.id).any?
  end

  def ad_attribution_sdks
    attribution_sdk_ids = Tag.find(24).android_sdks.pluck(:id)
    self.installed_sdks.select{|sdk| attribution_sdk_ids.include?(sdk["id"])}
  end

  def ranking_change
    newest_rank_snapshot = AndroidAppRankingSnapshot.last_valid_snapshot
    newest_rank = newest_rank_snapshot.android_app_rankings.where(android_app_id: self.id).first if newest_rank_snapshot
    if newest_rank
      week_ago = newest_rank_snapshot.created_at - 7.days
      last_weeks_rank_snapshot = AndroidAppRankingSnapshot.where(is_valid: true).where('created_at <=  ?', week_ago.end_of_day).first
      return 0 unless last_weeks_rank_snapshot
      last_weeks_rank = last_weeks_rank_snapshot.android_app_rankings.where(android_app_id: self.id).first

      if last_weeks_rank.blank?
        200 - newest_rank.rank + 1
      else
        last_weeks_rank.rank - newest_rank.rank
      end
    end
  end

  def to_csv_row
    developer = self.android_developer
    newest_snapshot = self.newest_android_app_snapshot
    hqs = self.headquarters(1)

    row = [
      self.id,
      self.app_identifier,
      newest_snapshot.try(:name),
      'AndroidApp',
      self.mobile_priority,
      nil,
      self.last_updated,
      self.android_fb_ad_appearances.present?,
      newest_snapshot.try(:in_app_purchase_min).present?,
      self.categories.try(:join, ", "),
      developer.try(:id),
      developer.try(:name),
      developer.try(:identifier),
      self.fortune_rank,
      developer.try(:get_website_urls).try(:join, ', '),
      'http://www.mightysignal.com/app/app#/app/android/' + self.id.to_s,
      developer.present? ? 'http://www.mightysignal.com/app/app#/publisher/android/' + developer.id.to_s : nil,
      self.ratings_all_count,
      self.downloads_human,
      hqs.map{|hq| hq[:street_number]}.join('|'),
      hqs.map{|hq| hq[:street_name]}.join('|'),
      hqs.map{|hq| hq[:city]}.join('|'),
      hqs.map{|hq| hq[:state]}.join('|'),
      hqs.map{|hq| hq[:country]}.join('|'),
      hqs.map{|hq| hq[:postal_code]}.join('|'),
    ]
    AppStore.enabled.order("display_priority IS NULL, display_priority ASC").each do |store|
      row << (store.country_code == 'US' ? self.user_base : nil)
    end
    row
  end

  def as_json(options={})
    newest_snapshot = self.newest_android_app_snapshot

    batch_json = {
      id: self.id,
      type: self.class.name,
      name: newest_snapshot.try(:name),
      platform: 'android',
      mobilePriority: self.mobile_priority,
      adSpend: self.old_ad_spend?,
      lastUpdated: self.last_updated,
      lastUpdatedDays: self.last_updated_days,
      categories: self.categories,
      seller: newest_snapshot.try(:seller),
      supportDesk: self.support_url,
      userBase: self.user_base,
      icon: self.icon_url,
      downloadsMin: newest_snapshot.try(:downloads_min),
      downloadsMax: newest_snapshot.try(:downloads_max),
      price: newest_snapshot.try(:price),
      rankingChange: self.ranking_change,
      fortuneRank: self.fortune_rank,
      appAvailable: self.app_available?,
      isInternational: self.international?,
      regions: self.region_codes,
      publisher: {
        id: self.try(:android_developer).try(:id),
        name: self.try(:android_developer).try(:name),
        websites: self.try(:android_developer).try(:get_website_urls)
      },
    }

    if options[:ads]
      batch_json.merge!({
        first_seen_ads_date: self.first_seen_ads_date,
        first_seen_ads_days: self.first_seen_ads_days,
        last_seen_ads_date: self.last_seen_ads_date,
        last_seen_ads_days: self.last_seen_ads_days,
        latest_facebook_ad: self.latest_facebook_ad.as_json({no_app: true}),
        ad_attribution_sdks: self.ad_attribution_sdks
      })
    end

    if options[:details]
      batch_json.merge!({
        downloads: self.downloads,
        playStoreId: newest_snapshot.try(:android_app_id),
        size: newest_snapshot.try(:size),
        requiredAndroidVersion: newest_snapshot.try(:required_android_version),
        contentRating: newest_snapshot.try(:content_rating),
        description: newest_snapshot.try(:description),
        currentVersion: newest_snapshot.try(:version),
        inAppPurchaseMin: newest_snapshot.try(:in_app_purchase_min),
        inAppPurchaseMax: newest_snapshot.try(:in_app_purchase_max),
        rating: newest_snapshot.try(:ratings_all_stars),
        ratingsCount: newest_snapshot.try(:ratings_all_count),
        appIdentifier: self.app_identifier,
        displayStatus: self.display_type,
        facebookAds: self.android_ads.take(10).as_json({no_app: true}),
        headquarters: self.headquarters
      })
    end

    if options[:user]
      batch_json[:following] = options[:user].following?(self)
    end

    if options[:account]
      batch_json[:following] = options[:account].following?(self)
    end

    batch_json[:rank] = self.rank if self.respond_to?(:rank)

    batch_json
  end

  def link(stage: :production)
    if stage == :production
      "http://mightysignal.com/app/app#/app/android/#{id}"
    elsif stage == :staging
      "http://ms-staging.com/app/app#/app/android/#{id}"
    end
  end

  def app_available?
    display_type != 'taken_down'
  end

  def get_newest_apk_snapshot
    self.apk_snapshots.where(scan_status: 1).first
  end

  def support_url
    self.newest_android_app_snapshot.try(:seller_url)
  end

  def last_updated
    self.newest_android_app_snapshot.try(:released).to_s
  end

  def ratings_all_count
    self.newest_android_app_snapshot.try(:ratings_all_count)
  end

  def latest_facebook_ad
    latest_ad
  end

  def last_updated_days
    if released = self.newest_android_app_snapshot.try(:released)
      (Time.now.to_date - released.to_date).to_i
    end
  end

  def released_days
    (Date.today - created_at.to_date).to_i
  end

  def categories
    if newest_snapshot = self.newest_android_app_snapshot
      newest_snapshot.android_app_categories.map{|c| c.name}
    end
  end

  def seller_url
    self.newest_android_app_snapshot.try(:seller_url)
  end

  def old_ad_spend?
    self.android_fb_ad_appearances.present?
  end

  def headquarters(limit=100)
    android_developer.try(:headquarters, limit) || []
  end

  def downloads
    if newest_snapshot = self.newest_android_app_snapshot
      "#{newest_snapshot.downloads_min}-#{newest_snapshot.downloads_max}"
    end
  end

  def downloads_human
    if newest_snapshot = self.newest_android_app_snapshot
      "#{ActionController::Base.helpers.number_to_human(newest_snapshot.downloads_min)}-#{ActionController::Base.helpers.number_to_human(newest_snapshot.downloads_max)}"
    end
  end

  def sdk_response
    AndroidSdkService::App.get_sdk_response(id)
  end

  def tagged_sdk_response(only_show_tagged=false)
    AndroidSdkService::App.get_tagged_sdk_response(self.id, only_show_tagged)
  end

  def google_play_link
    "https://play.google.com/store/apps/details?id=#{app_identifier}"
  end

  def installed_sdks
    self.sdk_response[:installed_sdks]
  end

  def uninstalled_sdks
    self.sdk_response[:uninstalled_sdks]
  end

  def icon_url(size='300x300') # size should be string eg '350x350'
    if newest_android_app_snapshot.present?
      newest_android_app_snapshot.send("icon_url_#{size}").try(:gsub, /-rw$/, '')
    end
  end

  def last_apk_snapshot(scan_success: false)
    if scan_success
      self.apk_snapshots.where(scan_status: ApkSnapshot.scan_statuses[:scan_success]).order([:good_as_of_date, :id]).last
    else
      self.apk_snapshots.order(:good_as_of_date).last
    end
  end

  def invalidate_newest_apk_snapshot
    apk_snapshot = newest_successful_apk_snapshot

    apk_snapshot.update(scan_status: :invalidated)

    update_newest_apk_snapshot
  end

  def update_newest_apk_snapshot
     update(newest_apk_snapshot: newest_successful_apk_snapshot)
  end

  # @author Jason Lew
  # @note Used right now in PackageSearchWorker
  def newest_successful_apk_snapshot
    apk_snapshots.where(scan_status: ApkSnapshot.scan_statuses[:scan_success]).order(:good_as_of_date).last
  end

  private

  # delete old method
  def get_sdks(sdk_apk, first_last)
    r = Hash.new
    sdk_apk.each{|sdk, apk| r[sdk] = ApkSnapshot.find(apk).send(first_last) }
    sdks = AndroidSdk.where(id:sdk_apk.map(&:first),flagged: false)
    sdks.each{ |sdk| sdk.send("#{first_last}=",r[sdk.id]) }
    sdks
  end

  class << self

    def dedupe
      # find all models and group them on keys which should be common
      grouped = all.group_by{|model| [model.app_identifier] }
      grouped.values.each do |duplicates|
        # the first one we want to keep right?
        first_one = duplicates.shift # or pop for last one
        # if there are any more left, they are duplicates
        # so delete all of them
        duplicates.each do |double|
          puts "double: #{double.app_identifier}"
          double.destroy # duplicates can now be destroyed
        end
      end
    end

  end
end
