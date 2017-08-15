class AndroidApp < ActiveRecord::Base
  include AppAds
  include MobileApp

  class NoESData; end

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

  has_many :tag_relationships, as: :taggable
  has_many :tags, through: :tag_relationships

  has_many :apk_snapshot_scrape_failures
  has_many :apk_snapshot_jobs
  has_many :apk_snapshot_scrape_exceptions
  has_many :weekly_batches, as: :owner
  has_many :activities, through: :weekly_batches
  has_many :follow_relationships, as: :followable
  has_many :followers, as: :followable, through: :follow_relationships

  enum user_base: [:elite, :strong, :moderate, :weak]

  enum display_type: [:normal, :taken_down, :foreign, :paid]

  serialize :regions, JSON

  has_many :android_ads, :foreign_key => :advertised_app_id

  ad_table :android_ads
  # update_index('apps#android_app') { self } if Rails.env.production?

  attr_writer :es_client

  def es_client
    @es_client ||= AppsIndex::AndroidApp
    @es_client
  end

  def mobile_priority
      if newest_android_app_snapshot and newest_android_app_snapshot.released
        if newest_android_app_snapshot.released > 2.months.ago
          return 'high'
        elsif newest_android_app_snapshot.released > 4.months.ago
          return 'medium'
        end
    end
    'low'
  end

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

  def major_publisher?
    self.android_developer ? self.android_developer.is_major_publisher? : false
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
      self.link,
      developer.try(:link),
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

  def platform
    'android'
  end

  def last_scanned
    newest_successful_apk_snapshot ? newest_successful_apk_snapshot.good_as_of_date : nil
  end

  def as_json(options={})
    newest_snapshot = self.newest_android_app_snapshot

    batch_json = {
      id: self.id,
      type: self.class.name,
      name: newest_snapshot.try(:name),
      platform: self.platform,
      mobilePriority: self.mobile_priority,
      adSpend: self.ad_spend? || self.old_ad_spend?,
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
        facebookAds: self.android_ads.as_json({no_app: true}),
        headquarters: self.headquarters,
        isMajorApp: self.is_major_app? || self.major_app_tag?
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

  # fetch SDK information from elasticsearch
  def sdk_json
    data = es_info
    if data == NoESData
      installed = uninstalled = []
    else
      installed = data.fetch('installed_sdks') || []
      uninstalled = data.fetch('uninstalled_sdks') || []
    end
    combined = [installed, uninstalled].map do |es_sdks|
      hydrated_sdks = AndroidSdk.where(id: es_sdks.map { |x| x['id'] }).map { |s| s.api_json(short_form: true) }
      hydrated_sdks.each do |sdk|
        es_sdk_data = es_sdks.find { |x| x['id'] == sdk[:id] }
        sdk[:first_seen_date] = es_sdk_data['first_seen_date']
        sdk[:last_seen_date] = es_sdk_data['last_seen_date']
      end
    end
    {
      installed_sdks: combined.first,
      uninstalled_sdks: combined.last
    }
  end

  def api_json(options = {})
    result = {
      id: id,
      platform: :android,
      google_play_id: app_identifier,
      mobile_priority: mobile_priority,
      has_ad_spend: ad_spend?,
      user_base: user_base
    }
    result[:publisher] = android_developer.present? ? android_developer.api_json(short_form: true) : nil
    data = es_info
    if data != NoESData
      result.merge!(
        first_scanned_date: data['first_scanned'],
        last_scanned_date: data['last_scanned'],
        first_seen_ads_date: data['first_seen_ads'],
        last_seen_ads_date: data['last_seen_ads'])
    end
    result[:taken_down] = !app_available?
    result.merge!(newest_android_app_snapshot.try(:api_json) || {})
    result.merge!(sdk_json) unless options[:short_form]
    result
  end

  def es_info
    result = es_client.query(
      term: { 'id' => id }
    ).first
    result.present? ? result.attributes : NoESData
  end

  def link(stage: :production, utm_source: nil)
    app_link = if stage == :production
      "https://mightysignal.com/app/app#/app/android/#{id}"
    elsif stage == :staging
      "https://staging.mightysignal.com/app/app#/app/android/#{id}"
    end
    app_link += "?utm_source=#{utm_source}" if utm_source
    app_link
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

  def ad_spend?
    self.android_ads.present?
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

  def user_base_display_score
    self.class.user_bases[user_base]
  end

  def versions_history
    android_app_snapshots.pluck(:version, :released).uniq.select{|x| x[0] and x[1]}.map {|x| {version: x[0], released: x[1]}}
  end

  def ratings_history
    run_length_encode_app_snapshot_fields(android_app_snapshots, [:ratings_all_count, :ratings_all_stars])
  end

  def downloads_history
    run_length_encode_app_snapshot_fields(android_app_snapshots, [:downloads_min, :downloads_max])
  end

  def as_external_dump_json
      app = self

      # Only these attributes will be output in the final response.
      white_list = ["id", "name", "price", "seller_url",
          "current_version", "released", "top_dev",
          "in_app_purchases", "required_android_version",
          "content_rating", "seller", "in_app_purchase_min",
          "in_app_purchase_max", "downloads_min", "downloads_max",
          "icon_url", "categories", "publisher", "platform", "google_play_id",
          "user_base", "last_updated", "all_version_rating",
          "all_version_ratings_count", "first_scanned", "last_scanned",
          "description", "installed_sdks", "uninstalled_sdks",
          "mobile_priority", "developer_google_play_identifier",
          "ratings_history", "versions_history", "downloads_history",
          "taken_down", "last_seen_ads_date", "first_seen_ads_date"
        ]

      rename = [
          ['ratings_all_stars', 'all_version_rating'],
          ['ratings_all_count', 'all_version_ratings_count'],
          ['icon_url_300x300', 'icon_url'],
          ['version', 'current_version']
          ]

      fields_from_app = [
          ['app_identifier', 'google_play_id'],
          ['mobile_priority', 'mobile_priority'],
          ['user_base', 'user_base'],
          ['last_updated', 'last_updated'],
          ['id', 'id'],
          ['downloads_history', 'downloads_history'],
          ['ratings_history', 'ratings_history'],
          ['versions_history', 'versions_history']
          ]

      app_obj = app.newest_android_app_snapshot.as_json || {}
      app_obj['mightysignal_app_version'] = '1'
      app_obj.merge!(app.sdk_response)

      app_obj["installed_sdks"] = app_obj[:installed_sdks].map{|sdk| sdk.slice("id", "name", "last_seen_date", "first_seen_date")}
      app_obj["installed_sdks"].map do |sdk|
        sdk["categories"] = AndroidSdk.find(sdk["id"]).tags.pluck(:name)
      end
      app_obj["uninstalled_sdks"] = app_obj[:uninstalled_sdks].map{|sdk| sdk.slice("id", "name", "last_seen_date", "first_seen_date", "first_unseen_date")}
      app_obj["uninstalled_sdks"].map do |sdk|
        sdk["categories"] = AndroidSdk.find(sdk["id"]).tags.pluck(:name)
      end

      if app.categories
        app_obj["categories"] = app.categories.map{|v| {"name" => v}}
      end

      if app.android_developer
        app_obj['publisher'] = app.android_developer.as_json.slice("name", "id")
        app_obj['publisher']['platform'] = platform
      end
      app_obj["platform"] = platform
      app_obj["seller_url"] = app.newest_android_app_snapshot.try(:seller_url) || ''
      app_obj["seller"] = app.newest_android_app_snapshot.try(:seller) || ''

      fields_from_app.map do |field, new_name|
          app_obj[new_name] = app.send(field).as_json
      end

      app_obj['last_seen_ads_date'] = app.last_seen_ads_date
      app_obj['first_seen_ads_date'] = app.first_seen_ads_date

      app_obj['has_ad_spend'] = app.ad_spend?
      app_obj['taken_down'] = !app.app_available?

      rename.map do |field, new_name|
          app_obj[new_name] = app_obj[field]
          app_obj.delete(field)
      end

      data = app.apk_snapshots.where("scan_status = ? OR status = ?",
        ApkSnapshot.scan_statuses[:scan_success], ApkSnapshot.scan_statuses[:scan_success]).
        group(:android_app_id).select('android_app_id',
          'max(good_as_of_date) as last_scanned',
          'min(good_as_of_date) as first_scanned')

      if data[0]
        app_obj["first_scanned_date"] = data[0].first_scanned.utc.iso8601
        app_obj["last_scanned_date"] = data[0].last_scanned.utc.iso8601
      end
      app_obj.slice(*white_list)
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
