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

  # Do not use the foreign type!
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
    last_release_date = nil
    if newest_android_app_snapshot and newest_android_app_snapshot.released
      last_release_date = newest_android_app_snapshot.released
    end
    AndroidApp.mobile_priority_from_date(last_release_date)
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
      self.ad_spend? || self.old_ad_spend?,
      self.first_seen_ads_date,
      self.last_seen_ads_date,
      newest_snapshot.try(:in_app_purchase_min).present?,
      self.categories.try(:join, ", "),
      developer.try(:id),
      developer.try(:name),
      developer.try(:identifier),
      self.fortune_rank,
      DomainLinker.new.publisher_to_domains('android', developer.id).try(:first, 10).try(:join, ', '),
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

  def self.platform
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
        websites: self.try(:android_developer).try(:get_website_urls),
        linkedin: self.try(:android_developer).try(:linkedin_handle),
        companySize: self.try(:android_developer).try(:company_size),
        crunchbase: self.try(:android_developer).try(:crunchbase_handle)
      },
    }

    if options[:ads]
      batch_json.merge!({
        first_seen_ads_date: self.first_seen_ads_date,
        first_seen_ads_days: self.first_seen_ads_days,
        last_seen_ads_date: self.last_seen_ads_date,
        last_seen_ads_days: self.last_seen_ads_days,
        # latest_facebook_ad: self.latest_facebook_ad.as_json({no_app: true}),
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
        rating: { rating: newest_snapshot.try(:ratings_all_stars), count: newest_snapshot.try(:ratings_all_count) },
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

  def current_version_code
    newest = self.newest_apk_snapshot
    if newest && !newest.version_code.nil?
      newest.version_code
    end
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
    android_app_snapshot_categories.map {|cat| cat.display_name}
  end

  def android_app_snapshot_categories
    if self.newest_android_app_snapshot
      self.newest_android_app_snapshot.android_app_categories
    else
      []
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

  def tagged_sdk_response(only_show_tagged=false)
    self.tagged_sdk_history(only_show_tagged)
  end

  def google_play_link
    "https://play.google.com/store/apps/details?id=#{app_identifier}"
  end

  def installed_sdks
    self.sdk_history[:installed_sdks]
  end

  def uninstalled_sdks
    self.sdk_history[:uninstalled_sdks]
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
    filter_older_versions_from_android_apk_snapshots(apk_snapshots.where(scan_status: ApkSnapshot.scan_statuses[:scan_success]).order(:good_as_of_date)).last
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

  def as_external_dump_json(extra_white_list: [], extra_from_app: [], extra_sdk_fields: [], extra_publisher_fields: [], include_sdk_history: true)
      app = self

      # Only these attributes will be output in the final response.
      white_list = ["id", "name", "price", "seller_url",
          "current_version", "released",
          "in_app_purchases", "required_android_version",
          "content_rating", "seller", "in_app_purchase_min",
          "in_app_purchase_max", "downloads_min", "downloads_max",
          "icon_url", "categories", "publisher", "platform", "google_play_id",
          "user_base", "last_updated", "all_version_rating",
          "all_version_ratings_count", "first_scanned", "last_scanned",
          "description", "installed_sdks", "uninstalled_sdks",
          "mobile_priority", "developer_google_play_identifier",
          "ratings_history", "versions_history", "downloads_history",
          "taken_down", "last_seen_ads_date", "first_seen_ads_date",
          "last_scanned_date", "first_scanned_date",
          "download_regions", "first_scraped"
          ] + extra_white_list + extra_from_app

      rename = [
          ['ratings_all_stars', 'all_version_rating'],
          ['ratings_all_count', 'all_version_ratings_count'],
          ['icon_url_300x300', 'icon_url'],
          ['version', 'current_version']
          ]

      fields_from_app = [
          ['app_identifier', 'google_play_id'],
          ['region_codes', 'download_regions'],
          ['mobile_priority', 'mobile_priority'],
          ['user_base', 'user_base'],
          ['last_updated', 'last_updated'],
          ['id', 'id'],
          ['downloads_history', 'downloads_history'],
          ['ratings_history', 'ratings_history'],
          ['versions_history', 'versions_history']
          ] + (extra_from_app.map { |field| [ field, field ] })

      sdk_fields = [
          "id",
          "name",
          "last_seen_date",
          "first_seen_date"
          ] + extra_sdk_fields

      publisher_fields = [
          "name",
          "id"
          ] + extra_publisher_fields

      app_obj = app.newest_android_app_snapshot.as_json || {}
      app_obj['mightysignal_app_version'] = '1'

      if include_sdk_history
        app_obj.merge!(app.sdk_history)
        app_obj["installed_sdks"] = app_obj[:installed_sdks].map{|sdk| sdk.slice(*sdk_fields)}
        app_obj["installed_sdks"].map do |sdk|
          sdk["categories"] = AndroidSdk.find(sdk["id"]).tags.pluck(:name)
        end
        app_obj["uninstalled_sdks"] = app_obj[:uninstalled_sdks].map{|sdk| sdk.slice(*(sdk_fields + ["first_unseen_date"]))}
        app_obj["uninstalled_sdks"].map do |sdk|
          sdk["categories"] = AndroidSdk.find(sdk["id"]).tags.pluck(:name)
        end
      end

      if app.android_app_snapshot_categories
        app_obj["categories"] = app.android_app_snapshot_categories.map{|x| x.as_json.slice(:id, :name)}
      end

      if app.android_developer
        app_obj['publisher'] = app.android_developer.as_json.slice(*publisher_fields)
        app_obj['publisher']['platform'] = platform
      end
      app_obj["platform"] = platform
      app_obj["seller_url"] = app.newest_android_app_snapshot.try(:seller_url) || ''
      app_obj["seller"] = app.newest_android_app_snapshot.try(:seller) || ''

      fields_from_app.map do |field, new_name|
          app_obj[new_name] = app.send(field).as_json
      end

      if app_obj['versions_history'] and app_obj['versions_history'].any?
        app_obj['first_scraped'] = app_obj['versions_history'][0]["released"]
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

  def self.bulk_export(ids:[], options: {})
      
      # Whitelist as a safeguard to prevent us from exporting any
      # attributes that we don't want to expose.
      attribute_whitelist = [
        "app_identifier",
        "user_base",
        "taken_down",
        "google_play_id",
        "publisher",
        "headquarters",
        "downloads_history",
        "ratings_history",
        "versions_history",
        "first_scraped",
        "id",
        "name",
        "price",
        "seller_url",
        "released",
        "description",
        "in_app_purchases",
        "required_android_version",
        "content_rating",
        "seller",
        "in_app_purchase_min",
        "in_app_purchase_max",
        "downloads_min",
        "downloads_max",
        "developer_google_play_identifier",
        "categories",
        "platform",
        "last_updated",
        "mobile_priority",
        "installed_sdks",
        "uninstalled_sdks",
        "has_fb_ad_spend",
        "all_version_rating",
        "all_version_ratings_count",
        "icon_url",
        "current_version",
        "download_regions",
        "first_scanned_date",
        "last_scanned_date"
      ]

      # List of attributes to pluck from respective collections

      attributes_from_app = [
        "id",
        "app_identifier",
        "region_codes",
        "user_base"
      ]

      snapshot_attributes = [
        "id",
        "name",
        "price",
        "seller_url",
        "version",
        "released",
        "description",
        "android_app_id",
        "in_app_purchases",
        "required_android_version",
        "content_rating",
        "seller",
        "ratings_all_stars",
        "ratings_all_count",
        "status",
        "in_app_purchase_min",
        "in_app_purchase_max",
        "downloads_min",
        "downloads_max",
        "icon_url_300x300",
        "developer_google_play_identifier"
      ]
      
      category_attributes = [
        "name",
        "category_id"
      ]

      sdk_attributes = [
        "id",
        "name",
        "last_seen_date",
        "first_seen_date",
        "activities"
      ]

      historical_attributes = [
        "created_at",
        "android_app_id",
        "downloads_min",
        "downloads_max",
        "ratings_all_count",
        "ratings_all_stars",
        "version",
        "released"
      ]

      domain_data_attributes = [
        "id",
        "domain",
        "street_number",
        "street_name",
        "sub_premise",
        "city",
        "postal_code",
        "state",
        "state_code",
        "country",
        "country_code",
        "lat",
        "lng"
      ]

      rename = [
        ['ratings_all_stars', 'all_version_rating'],
        ['ratings_all_count', 'all_version_ratings_count'],
        ['icon_url_300x300', 'icon_url'],
        ['version', 'current_version'],
        ['region_codes', 'download_regions']
      ]

      results = {}

      apps = AndroidApp.where(:id => ids).to_a
      
      ##
      # Step 1:
      #
      # Run bulk queries and build out info mappings in memory.
      #

      # Build app_id => newest_snapshot/category mapping
      # 
      # {
      #   app_id => [
      #     [ id, name, price, size, updated, seller_url, version, released, description, ... ] 
      #   ]
      # }
      #

      attributes_to_pluck = snapshot_attributes.map { |a| "android_app_snapshots.#{a}" } + category_attributes.map { |a| "android_app_categories.#{a}" }
      snaps_and_categories = AndroidAppSnapshot.where(:id => apps.map(&:newest_android_app_snapshot_id)).joins(:android_app_categories).pluck(*attributes_to_pluck)
      snapshots_history_attributes = AndroidAppSnapshot.where(:android_app_id => ids).pluck(*historical_attributes)

      snapshots_history_attributes_map = {}
      snapshots_history_attributes.each do |snapshot|
        app_id = snapshot[historical_attributes.index("android_app_id")]
        if snapshots_history_attributes_map[app_id]
          snapshots_history_attributes_map[app_id] << snapshot
        else
          snapshots_history_attributes_map[app_id] = [ snapshot ]
        end
      end

      # Build developer_id => developer_name mapping:
      #
      # {
      #   developer_id => "developer_name"
      # }

      android_developers = AndroidDeveloper.where(:id => apps.map(&:android_developer_id)).pluck(:id, :name)
      android_developers = Hash[*android_developers.flatten] # converts tuples in to {:id => :name} dict

 
      # Build developer_id to headquarters mapping:
      #
      # {
      #   developer_id => [ 
      #     {
      #       "id" => xxx
      #       "domain" => "xxxx"
      #       "street_number" => xxxx
      #     }
      #   ]
      # }

      developer_id_to_website_id = AndroidDevelopersWebsite.where(:android_developer_id => android_developers.keys).pluck(:android_developer_id, :website_id)

      developer_id_to_website_id_map = {}
      developer_id_to_website_id.each do |dw|
        if developer_id_to_website_id_map[dw[0]]
          developer_id_to_website_id_map[dw[0]] << dw[1]
        else
          developer_id_to_website_id_map[dw[0]] = [ dw[1] ]
        end
      end

      website_ids = developer_id_to_website_id.map{ |a| a[1] }
      website_id_to_domain_datum_id = WebsitesDomainDatum.where(:website_id => website_ids).pluck(:website_id, :domain_datum_id)
      website_id_to_domain_datum_id = Hash[*website_id_to_domain_datum_id.flatten] # again, convert into map. okay cause a website has a single domain datum

      domain_data_ids = website_id_to_domain_datum_id.values
      domain_data = DomainDatum.where(:id => domain_data_ids).pluck(*domain_data_attributes)
      domain_data_map = {} 
      domain_data.each do |dd|
        domain_data_map[dd[domain_data_attributes.index("id")]] = dd
      end
      domain_data = nil

      
      ##
      # Step 2:
      #
      # Build out app exports from mappings generated in first step
      # 

      apps.each do |app|
        result = {}
        
        attributes_from_app.each do |attribute|
          result[attribute] = app.send(attribute).as_json
        end

        result['taken_down'] = !app.app_available?
        result['google_play_id'] = result['app_identifier']

        pub_name = android_developers[app.android_developer_id]
        if pub_name
          result["publisher"] = {
            :id => app.android_developer_id,
            :name => pub_name,
            :platform => platform
          }.as_json
        end
        
        # Gather headquarter data if any

        headquarters = []
        website_ids = developer_id_to_website_id_map[app.android_developer_id]
        if website_ids
          website_ids.each do |website_id|
            domain_datum_id = website_id_to_domain_datum_id[website_id]
            dd = domain_data_map[domain_datum_id]
            next if dd.nil?
            headquarter = {}
            domain_data_attributes.each do |dd_attribute|
              next if dd_attribute == "id"
              headquarter[dd_attribute] = dd[domain_data_attributes.index(dd_attribute)]
            end
            headquarters << headquarter
          end
        end
        result["headquarters"] = headquarters.uniq[0..100] # limit to 100 headquarters

        # Gather versions, ratings, and download history if any

        historical_snapshots = snapshots_history_attributes_map[app.id]
        if historical_snapshots
          historical_download_snapshots = historical_snapshots.map { |s| [s[historical_attributes.index("downloads_min")], s[historical_attributes.index("downloads_max")], s[historical_attributes.index("created_at")]] }
          app_download_history = app.run_length_encode_app_snapshot_fields_from_fetched(historical_download_snapshots, [:downloads_min, :downloads_max, :created_at])
          result["downloads_history"] = app_download_history.as_json

          historical_ratings_snapshots = historical_snapshots.map { |s| [s[historical_attributes.index("ratings_all_count")], s[historical_attributes.index("ratings_all_stars")], s[historical_attributes.index("created_at")]] }
          app_ratings_history = app.run_length_encode_app_snapshot_fields_from_fetched(historical_ratings_snapshots, [:ratings_all_count, :ratings_all_stars, :created_at])
          result["ratings_history"] = app_ratings_history.as_json

          app_versions_history = historical_snapshots.map{|s|[s[historical_attributes.index("version")],s[historical_attributes.index("released")]]}.uniq.select{|x| x[0] and x[1]}.map {|x| {version: x[0], released: x[1]}}
          result["versions_history"] = app_versions_history.as_json

          if result['versions_history'] and result['versions_history'].any?
            result['first_scraped'] = result['versions_history'][0]["released"]
          end
        end

        results[app.id] = result
      end

      snaps_and_categories.each do |attributes_array|
        app_id = attributes_array[snapshot_attributes.index("android_app_id")]
        if !results[app_id]
          Bugsnag.notify(RuntimeError.new("Missing app snapshot entry for #{app_id}"))
          next
        end

        category_info = Hash[category_attributes.zip(attributes_array.last(category_attributes.length))]
        category_info["id"] = category_info["category_id"] # Rename category_id to id
        category_info.delete("category_id")

        if results[app_id] and results[app_id]["categories"]
          results[app_id]["categories"] << category_info
        else
          result = {}
          snapshot_attributes.each_with_index do |value, i|
            next if value == "id" or value == "android_app_id"
            result[value] = attributes_array[i]
          end
          result["categories"] = [ category_info ]
          result["platform"] = platform

          result["last_updated"] = result["released"].as_json
          
          result["mobile_priority"] = AndroidApp.mobile_priority_from_date(attributes_array[snapshot_attributes.index("released")])

          results[app_id] = results[app_id].merge(result)
        end
      end

      if options[:include_sdk_history]
        sdk_ids = Set.new
    
        apps.each do |app|
          sdk_history = app.sdk_history
          if results[app.id]
            results[app.id]["installed_sdks"] = sdk_history[:installed_sdks].map{|sdk| sdk.slice(*sdk_attributes)}
            results[app.id]["uninstalled_sdks"] = sdk_history[:uninstalled_sdks].map{|sdk| sdk.slice(*(sdk_attributes + ["first_unseen_date"]))}
          else
            Bugsnag.notify(RuntimeError.new("Missing app snapshot entry for #{app.id}"))
          end
    
          sdk_history[:installed_sdks].each do |sdk|
            sdk_ids << sdk["id"]
          end
          sdk_history[:uninstalled_sdks].each do |sdk|
            sdk_ids << sdk["id"]
          end
        end
        
        sdks_to_tags_tuples = AndroidSdk.where(:id => sdk_ids.to_a).joins(:tags).pluck("android_sdks.id", "tags.name")
    
        sdks_to_tags_map = {}
        sdks_to_tags_tuples.each do |sdk_id, tag_name|
          if sdks_to_tags_map[sdk_id]
            sdks_to_tags_map[sdk_id] << tag_name
          else
            sdks_to_tags_map[sdk_id] = [ tag_name ]
          end
        end
    
        sdks_to_tags_map.keys.each do |sdk_id|
          sdks_to_tags_map[sdk_id] = sdks_to_tags_map[sdk_id].uniq
        end

        results.values.each do |result|
          result["installed_sdks"].each {|sdk| sdk["categories"] = sdks_to_tags_map[sdk["id"]]} if result["installed_sdks"]
          result["uninstalled_sdks"].each {|sdk| sdk["categories"] = sdks_to_tags_map[sdk["id"]]} if result["uninstalled_sdks"]
        end
      end


      ##
      # Step 3:
      #
      # Run final aggregate queries and finish building app export objects.
      # 

      ad_stats = AndroidAd.where(:advertised_app_id => apps.map(&:id)).select('advertised_app_id, min(date_seen) as created_at, max(date_seen) as updated_at').group(:advertised_app_id)
      ad_stats.each do |ad_stat|
        if results[ad_stat.advertised_app_id]
          results[ad_stat.advertised_app_id]["first_seen_ads_date"] = ad_stat.created_at
          results[ad_stat.advertised_app_id]["last_seen_ads_date"] = ad_stat.updated_at
          results[ad_stat.advertised_app_id]["has_fb_ad_spend"] = true
        else
          Bugsnag.notify(RuntimeError.new("Missing app snapshot entry for #{ad_stat.advertised_app_id}"))
        end
      end

      app_missing_ads = apps.map(&:id) - ad_stats.map(&:advertised_app_id)
      app_missing_ads.each do |app_id|
        if results[app_id]
          results[app_id]['has_fb_ad_spend'] = false
        else
          Bugsnag.notify(RuntimeError.new("Missing app snapshot entry for #{app_id}"))
        end
      end

      results.values.each do |app|
        rename.map do |field, new_name|
          app[new_name] = app[field]
          app.delete(field)
        end
      end
      
      scan_statuses = ApkSnapshot.where("scan_status = ? OR status = ?",
        ApkSnapshot.scan_statuses[:scan_success], ApkSnapshot.scan_statuses[:scan_success])
        .where(:android_app_id => apps.map(&:id))
        .group(:android_app_id).select('android_app_id',
          'max(good_as_of_date) as last_scanned',
          'min(good_as_of_date) as created_at')
      
      scan_statuses.each do |scan_status|
        if results[scan_status.android_app_id]
          results[scan_status.android_app_id]["first_scanned_date"] = scan_status.created_at.utc.iso8601
          results[scan_status.android_app_id]["last_scanned_date"] = scan_status.last_scanned.utc.iso8601
        else
          Bugsnag.notify(RuntimeError.new("Missing app snapshot entry for #{scan_status.android_app_id}"))
        end
      end
      
      results.each do |app_id, result|
        results[app_id] = result.slice(*attribute_whitelist)
      end

      results
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

    def mobile_priority_from_date(date)
      if date
        if date > 2.months.ago
          return 'high'
        elsif date > 4.months.ago
          return 'medium'
        end
      end
      'low'
    end

    def validate_snapshot_history(app_id)
      # Function to cleanup install events associated with apk scan system ping ponging between
      # device specific APK version.
      app = AndroidApp.find(app_id)
      snaps = app.apk_snapshots
      good_snaps = app.filter_older_versions_from_android_apk_snapshots(snaps)
      bad_snaps = Set.new(snaps) - Set.new(good_snaps)
      last_snap_was_bad = false
      snaps.each do |snap|
        if bad_snaps.include?(snap)
          puts "invalidate because bad id: #{snap.id} version: #{snap.version}, #{snap.version_code}"
          snap.invalidate_activities!
          last_snap_was_bad = true
        elsif last_snap_was_bad and good_snaps.include?(snap)
          # Invalidate the next good snapshot's activities after
          # a bad snapshot. This potentially removes good activities
          # as well, but I think it's the best we can without getting really
          # complicated.
          puts "invalidate because after bad id: #{snap.id} version: #{snap.version}, #{snap.version_code}"
          snap.invalidate_activities!
        end

        if !bad_snaps.include?(snap)
          last_snap_was_bad = false
        end
      end
    end


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
