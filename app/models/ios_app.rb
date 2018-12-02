# == Schema Information
#
# Table name: ios_apps
#
#  id                         :integer          not null, primary key
#  created_at                 :datetime
#  updated_at                 :datetime
#  app_identifier             :integer
#  app_id                     :integer
#  newest_ios_app_snapshot_id :integer
#  user_base                  :integer
#  mobile_priority            :integer
#  released                   :date
#  newest_ipa_snapshot_id     :integer
#  display_type               :integer          default(0)
#  ios_developer_id           :integer
#  source                     :integer
#  fb_app_id                  :integer
#

class IosApp < ActiveRecord::Base
  include AppAds
  include MobileApp

  class NoESData; end

  validates :app_identifier, uniqueness: true
  # validates :app_stores, presence: true #can't have an IosApp if it's not connected to an App Store

  has_many :ipa_snapshot_job_exceptions
  has_many :ios_app_snapshots
  belongs_to :app
  has_many :ios_fb_ad_appearances
  has_many :ios_app_download_snapshots
  has_many :ipa_snapshots
  has_many :ipa_snapshot_lookup_failures

  has_many :class_dumps, through: :ipa_snapshots

  has_many :ios_apps_websites
  has_many :websites, through: :ios_apps_websites

  has_many :listables_lists, as: :listable
  has_many :lists, through: :listables_lists

  belongs_to :newest_ios_app_snapshot, class_name: 'IosAppSnapshot', foreign_key: 'newest_ios_app_snapshot_id'
  has_many :ios_app_current_snapshots
  has_many :ios_app_current_snapshot_backups
  belongs_to :newest_ipa_snapshot, class_name: 'IpaSnapshot', foreign_key: 'newest_ipa_snapshot_id'

  has_many :app_stores_ios_apps
  has_many :app_stores, -> { uniq }, through: :app_stores_ios_apps
  has_many :app_store_ios_apps_backups
  has_many :app_store_backups, source: :app_store, through: :app_store_ios_apps_backups

  belongs_to :ios_developer

  has_many :weekly_batches, as: :owner
  has_many :activities, through: :weekly_batches
  has_many :follow_relationships, as: :followable
  has_many :followers, through: :follow_relationships
  has_many :ios_fb_ads

  has_many :ios_app_rankings

  has_many :owner_twitter_handles, as: :owner
  has_many :twitter_handles, through: :owner_twitter_handles

  has_many :tags, through: :tag_relationships
  has_many :tag_relationships, as: :taggable

  enum mobile_priority: [:high, :medium, :low] # this enum isn't used anymore. mobile_priority is determined by the mobile priority function
  enum user_base: [:elite, :strong, :moderate, :weak] # this order matters...don't change or add more
  enum display_type: [:normal, :taken_down, :foreign, :device_incompatible, :paid, :not_ios]
  enum source: [:epf_weekly, :ewok, :itunes_top_200, :epf_incremental, :ad_intel, :rankings]

  scope :is_ios, ->{where.not(display_type: display_types[:not_ios])}

  ad_table :ios_fb_ads
  # update_index('apps#ios_app') { self } if Rails.env.production?

  WHITELISTED_APPS = Rails.env.production? ? [404249815, 297606951, 447188370, 368677368, 324684580, 477128284, 529479190, 547702041,591981144,618783545,317469184,401626263,1094591345,886427730] : IosApp.pluck(:id).sample(14)

  attr_writer :es_client

  def es_client
    @es_client ||= AppsIndex::IosApp
    @es_client
  end

  def app_store_available
    app_stores_ios_apps.any? && display_type != IosApp.display_types[:not_ios]
  end

  def invalidate_newest_ipa_snapshot
    ipa_snapshot = get_last_ipa_snapshot(scan_success: true)

    ipa_snapshot.update(scan_status: :invalidated)

    update_newest_ipa_snapshot
  end

  def update_newest_ipa_snapshot
    ipa_snapshot = get_last_ipa_snapshot(scan_success: true)

    self.update(newest_ipa_snapshot: ipa_snapshot)
  end

  def get_newest_download_snapshot
    self.ios_app_download_snapshots.max_by do |snapshot|
      snapshot.updated_at
    end
  end

  def get_last_ipa_snapshot(scan_success: false)
    if scan_success
      self.ipa_snapshots.where(scan_status: IpaSnapshot.scan_statuses[:scanned]).order([:good_as_of_date, :id]).last
    else
      self.ipa_snapshots.order(:good_as_of_date).last
    end
  end

  def get_company
    self.websites.each do |w|
      if w.company.present?
        return w.company
      end
    end
    return nil
  end

  # allow stubbing of getter for test
  def fb_app_data(getter: nil)
    return nil unless fb_app_id.present?
    getter ||= FbAppData.new(fb_app_id)
    getter.latest
  end

  def monthly_active_users
    mau = fb_app_data.try(:[], 'monthly_active_users').to_i
    mau <= 1 ? nil : mau
  end

  def monthly_active_users_rank
    fb_app_data.try(:[], 'monthly_active_users_rank')
  end

  def daily_active_users
    dau = fb_app_data.try(:[], 'daily_active_users').to_i
    dau == 0 ? nil : dau
  end

  def daily_active_users_rank
    fb_app_data.try(:[], 'daily_active_users_rank')
  end

  def weekly_active_users
    wau = fb_app_data.try(:[], 'weekly_active_users').to_i
    wau == 0 ? nil : wau
  end

  def self.platform
    'ios'
  end


  def as_json(options={})
    newest_snapshot = self.newest_ios_app_snapshot

    batch_json = {
      id: self.id,
      type: self.class.name,
      platform: platform,
      releaseDate: self.release_date,
      name: self.name,
      mobilePriority: mobile_priority,
      userBase: self.international_userbase(user_bases: options[:user_bases]),
      userBases: self.scored_user_bases,
      releasedDays: self.released_days,
      lastUpdated: self.last_updated,
      lastUpdatedDays: self.last_updated_days,
      seller: self.seller,
      supportDesk: self.support_url,
      categories: self.categories,
      icon: self.icon_url,
      adSpend: self.ad_spend? || self.old_ad_spend?,
      price: first_international_snapshot['price'] || newest_snapshot.try(:price),
      currency: self.currency,
      rankingChange: self.ranking_change,
      appAvailable: app_store_available,
      appStoreLink: self.app_store_link,
      appStores: {totalCount: AppStore.enabled.count, availableIn: self.app_stores.map{|store| {name: store.name, country_code: store.country_code}}},
      isInternational: self.international?,
      fortuneRank: self.fortune_rank,
      publisher: {
        id: self.try(:ios_developer).try(:id),
        name: self.try(:ios_developer).try(:name) || first_international_snapshot['seller_name'],
        websites: self.try(:ios_developer).try(:get_website_urls),
        linkedin: self.try(:ios_developer).try(:linkedin_handle),
        companySize: self.try(:ios_developer).try(:company_size),
        crunchbase: self.try(:ios_developer).try(:crunchbase_handle)
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

    if options[:engagement]
      batch_json.merge!({
        dau: ActionController::Base.helpers.number_to_human(self.daily_active_users),
        wau: ActionController::Base.helpers.number_to_human(self.weekly_active_users),
        mau: ActionController::Base.helpers.number_to_human(self.monthly_active_users),
        dau_rank: ActionController::Base.helpers.number_to_human(self.daily_active_users_rank),
        mau_rank: ActionController::Base.helpers.number_to_human(self.monthly_active_users_rank),
      })
    end

    if options[:details]
      batch_json.merge!({
        currentVersion: self.version,
        currentVersionDescription: self.release_notes,
        rating: self.rating,
        ratings: self.ratings,
        inAppPurchases: newest_snapshot.try(:ios_in_app_purchases).try(:any?),
        appIdentifier: self.app_identifier,
        appStoreId: self.developer_app_store_id,
        size: self.size,
        requiredIosVersion: self.required_ios_version,
        recommendedAge: self.recommended_age,
        description: self.description,
        facebookAds: self.ios_fb_ads.has_image.as_json({no_app: true}),
        headquarters: self.headquarters,
        isMajorApp: self.is_major_app?
      })
    end

    batch_json[:rank] = self.rank if self.respond_to?(:rank)

    if options[:user]
      batch_json[:following] = options[:user].following?(self)
      batch_json[:adSpend] = options[:user].account.can_view_ad_spend? ? self.ad_spend? : self.old_ad_spend?
    end

    if options[:account]
      batch_json[:following] = options[:account].following?(self)
    end

    batch_json
  end

  def size
    first_international_snapshot['size'] || newest_ios_app_snapshot.try(:size)
  end

  def required_ios_version
    first_international_snapshot['required_ios_version'] || newest_ios_app_snapshot.try(:required_ios_version)
  end

  def recommended_age
    first_international_snapshot['recommended_age'] || newest_ios_app_snapshot.try(:recommended_age)
  end

  def description
    first_international_snapshot['description'] || newest_ios_app_snapshot.try(:description)
  end

  def last_scanned
    get_last_ipa_snapshot(scan_success: true).try(:good_as_of_date)
  end

  def developer_app_store_id
    first_international_snapshot['developer_app_store_identifier'] || newest_ios_app_snapshot.try(:developer_app_store_identifier)
  end

  def categories
    IosSnapshotAccessor.new.category_names_from_ios_app(self)
  end

  def user_bases
    IosSnapshotAccessor.new.user_base_details_from_ios_app(self)
  end

  def scored_user_bases
    country_count = AppStore.enabled.count
    self.user_bases.map do |userbase|
      display_priority = AppStore.find_by(country_code: userbase[:country_code]).display_priority - 1
      base = userbase[:user_base] || 'weak'
      base_score = IosApp.user_bases[base]
      score = base_score * country_count + display_priority
      userbase.merge({ score: score })
    end.sort { |a, b| a[:score] <=> b[:score] }
  end

  def user_base_display_score
    self.scored_user_bases.first[:score]
  end

  def rating
    intl_snapshot = first_international_snapshot
    if intl_snapshot
      {rating: intl_snapshot['ratings_all_stars'], country_code: intl_snapshot['app_store'].try(:country_code), count: intl_snapshot['ratings_all_count']}
    else
      {country_code: 'US', rating: newest_ios_app_snapshot.try(:ratings_all_stars)}
    end
  end

  def ratings
    IosSnapshotAccessor.new.store_and_rating_details_from_ios_app(self)
  end

  def ratings_info(include_current_version_ratings: true, include_taken_down_countries: false)
    ratings_details = IosSnapshotAccessor.new.store_and_rating_details_from_ios_app(self, include_current: include_current_version_ratings)
    return ratings_details if include_taken_down_countries

    active_country_codes = app_stores.map {|x| x.country_code}
    ratings_details.select {|user_base_record|
      active_country_codes.include? user_base_record[:country_code]
    }
  end

  # def ratings_count
  #   intl_snapshot = first_international_snapshot
  #   if intl_snapshot
  #     {ratings_count: intl_snapshot['ratings_all_count'], country_code: intl_snapshot['app_store'].try(:country_code)}
  #   else
  #     {country_code: 'US', ratings_count: newest_ios_app_snapshot.try(:ratings_all_count)}
  #   end
  # end

  def latest_facebook_ad
    latest_ad
  end

  def international?
    !app_stores.pluck(:country_code).include?('US')
  end

  def international_userbase(user_bases: nil)
    if user_bases.present?
      intl_snapshot = first_international_snapshot(user_bases: user_bases)
      return intl_snapshot ? {user_base: intl_snapshot['user_base'], country_code: intl_snapshot['app_store'].try(:country_code)} : {user_base: self.user_base, country_code: 'US'} # FIX: app_store
    end
    scored_user_bases.first
  end

  def first_international_snapshot(country_code: nil, user_bases: nil)
    IosSnapshotAccessor.new.first_international_snapshot_hash_from_ios_app(self, country_code: country_code, user_bases: user_bases)
  end

  def old_ad_spend?
    self.ios_fb_ad_appearances.any?
  end

  def ad_spend?
    self.ios_fb_ads.any?
  end

  def seller_url
    first_international_snapshot['seller_url'] || self.newest_ios_app_snapshot.try(:seller_url)
  end

  def support_url
    self.newest_ios_app_snapshot.try(:support_url)
  end

  def get_website_urls
    self.websites.pluck(:url).uniq
  end

  def seller
    first_international_snapshot['seller'] || newest_ios_app_snapshot.try(:seller) # FIX: seller
  end

  def app_store_link
    app_store = first_international_snapshot.blank? ? 'us' : first_international_snapshot['app_store'].country_code.downcase
    "https://itunes.apple.com/#{app_store}/app/id#{self.app_identifier}"
  end

  def last_updated
    first_international_snapshot['released'].try(:to_s) || newest_ios_app_snapshot.try(:released).try(:to_s)
  end

  def top_200_rank
    self.ios_app_rankings.last.rank
  end

  def is_in_top_200?
    newest_rank_snapshot = IosAppRankingSnapshot.last_valid_snapshot
    return false unless newest_rank_snapshot
    newest_rank_snapshot.ios_app_rankings.where(ios_app_id: self.id).any?
  end

  def ranking_change
    newest_rank_snapshot = IosAppRankingSnapshot.last_valid_snapshot
    newest_rank = newest_rank_snapshot.ios_app_rankings.where(ios_app_id: self.id).first if newest_rank_snapshot
    if newest_rank
      week_ago = newest_rank_snapshot.created_at - 7.days
      last_weeks_rank_snapshot = IosAppRankingSnapshot.where(is_valid: true).where('created_at <=  ?', week_ago.end_of_day).first
      return 0 unless last_weeks_rank_snapshot
      last_weeks_rank = last_weeks_rank_snapshot.ios_app_rankings.where(ios_app_id: self.id).first

      if last_weeks_rank.blank?
        200 - newest_rank.rank + 1
      else
        last_weeks_rank.rank - newest_rank.rank
      end
    end
  end

  def last_updated_days
    released = first_international_snapshot['released'] || newest_ios_app_snapshot.try(:released)
    if released
      (Time.now.to_date - released.to_date).to_i
    end
  end

  def ratings_all_count
    first_international_snapshot['ratings_all_count'] || newest_ios_app_snapshot.try(:ratings_all_count)
  end

  def total_rating_count #includes international snapshots
    ratings.inject(0) {|sum, hash| sum + hash[:ratings_count].to_i}
  end

  def released_days
    released =  first_international_snapshot['first_released'] || newest_ios_app_snapshot.try(:first_released)
    released ? (Date.today - released).to_i : 0
  end

  def website
    self.get_website_urls.first
  end

  def icon_url(size='350x350') # size should be string eg '350x350'
    url = first_international_snapshot['icon_url_100x100'] || newest_ios_app_snapshot.try(:send, "icon_url_#{size}")
    IosApp.convert_icon_url_to_https(url)
  end

  def tagged_sdk_response(only_show_tagged=false)
    self.tagged_sdk_history(only_show_tagged)
  end

  def installed_sdks
    self.sdk_history[:installed_sdks]
  end

  def uninstalled_sdks
    self.sdk_history[:uninstalled_sdks]
  end

  def fortune_rank
    self.ios_developer.try(:fortune_1000_rank)
  end

  def major_publisher?
    self.ios_developer ? self.ios_developer.is_major_publisher? : false
  end

  def headquarters(limit=100)
    ios_developer.try(:headquarters, limit) || []
  end

  def release_date
    first_international_snapshot['first_released'] || newest_ios_app_snapshot.try(:first_released)
  end

  def name
    first_international_snapshot['name'] || newest_ios_app_snapshot.try(:name)
  end

  def price
    snapshot = first_international_snapshot
    if snapshot
      return (snapshot['price'].to_i > 0) ? "$#{snapshot['price']} #{snapshot['currency']}" : 'Free'
    end

    snapshot = newest_ios_app_snapshot
    if snapshot
      return (snapshot.price.to_i > 0) ? "$#{snapshot.price} #{snapshot.try(:currency)}" : 'Free'
    end
  end

  def currency
    first_international_snapshot['currency'] || 'USD'
  end

  def version
    first_international_snapshot['version'] || newest_ios_app_snapshot.try(:version)
  end

  def release_notes
    first_international_snapshot['release_notes'] || newest_ios_app_snapshot.try(:release_notes)
  end

  def versions_history
    # TODO change this to use the international snapshots table once it stores historical data.
    ios_app_snapshots.pluck(:version, :released).uniq.select{|x| x[0] and x[1]}.map {|x| {version: x[0], released: x[1]}}
  end

  def ratings_history
    run_length_encode_app_snapshot_fields(ios_app_snapshots, [:ratings_all_count, :ratings_all_stars])
  end

  def to_csv_row(can_view_support_desk=false)
    # li "CREATING HASH FOR #{app.id}"
    developer = self.ios_developer
    newest_snapshot = self.newest_ios_app_snapshot
    hqs = self.headquarters(1)

    domains = ''
    if ! developer.nil?
      domains = DomainLinker.new.publisher_to_domains('ios', developer.id).try(:first, 10).try(:join, ', ')
    end

    row = [
      self.id,
      self.app_identifier,
      self.name,
      'IosApp',
      self.mobile_priority,
      self.release_date,
      self.last_updated,
      self.ad_spend? || self.old_ad_spend?,
      self.first_seen_ads_date,
      self.last_seen_ads_date,
      newest_snapshot.try(:ios_in_app_purchases).try(:any?),
      self.categories.try(:join, ", "),
      developer.try(:id),
      developer.try(:name),
      developer.try(:identifier),
      self.fortune_rank,
      domains,
      self.link,
      developer.try(:link),
      self.ratings_all_count,
      nil, #downloads for android
      hqs.map{|hq| hq[:street_number]}.join('|'),
      hqs.map{|hq| hq[:street_name]}.join('|'),
      hqs.map{|hq| hq[:city]}.join('|'),
      hqs.map{|hq| hq[:state]}.join('|'),
      hqs.map{|hq| hq[:country]}.join('|'),
      hqs.map{|hq| hq[:postal_code]}.join('|'),
    ]
    IosSnapshotAccessor.new.user_base_values_from_ios_app(self).each do |user_base|
      row << IosSnapshotAccessor.new.user_base_name(user_base)
    end
    row
  end

  ###############################
  # Mobile priority methods
  ###############################

  def mobile_priority
    snapshot = first_international_snapshot

    release_date = nil
    release_date = snapshot['released'] if snapshot

    self.class.mobile_priority_from_date(released: release_date)
  end

  ########################
  # User Base methods
  ########################

  def set_user_base
    logger.info "updating user base"
    begin
      if self.newest_ios_app_snapshot.ratings_per_day_current_release >= 7 || self.newest_ios_app_snapshot.ratings_all_count >= 50e3
        self.user_base = :elite
      elsif self.newest_ios_app_snapshot.ratings_per_day_current_release >= 1 || self.newest_ios_app_snapshot.ratings_all_count >= 10e3
        self.user_base = :strong
      elsif self.newest_ios_app_snapshot.ratings_per_day_current_release >= 0.1 || self.newest_ios_app_snapshot.ratings_all_count >= 100
        self.user_base = :moderate
      else
        self.user_base = :weak
      end
      self.save
    rescue => e
      logger.info "Warning: couldn't update user_base for IosApp with id #{self.id}"
      logger.info e
    end
  end

  def link(stage: :production, utm_source: nil)
    app_link = if stage == :production
      "https://mightysignal.com/app/app#/app/ios/#{id}"
    elsif stage == :staging
      "https://staging.mightysignal.com/app/app#/app/ios/#{id}"
    end
    app_link += "?utm_source=#{utm_source}" if utm_source
    app_link
  end

  def reset_app_data
    update!(display_type: :normal)
    AppStoreInternationalService.scrape_ios_apps([id], live: true)
    AppStoreSnapshotServiceWorker.new.perform(nil, id)
    puts 'sleeping to allow intl scrapes'
    sleep 3
    AppStoreDevelopersWorker.new.create_by_ios_app_id(id)
  end

  def self.bulk_export(ids:[], options: {})

      # Whitelist as a safeguard to prevent us from exporting any
      # attributes that we don't want to expose.

      attribute_whitelist = [
        "last_seen_ads_date",
        "last_updated",
        "seller_url",
        "current_version",
        "has_in_app_purchases",
        "id",
        "first_seen_ads_date",
        "platform",
        "support_url",
        "seller",
        "headquarters",
        "original_release_date",
        "uninstalled_sdks",
        "all_version_rating",
        "description",
        "price",
        "has_ad_spend",
        "categories",
        "name",
        "installed_sdks",
        "publisher",
        "content_rating",
        "mobile_priority",
        "user_base",
        "last_scanned_date",
        "app_store_id",
        "current_version_ratings_count",
        "current_version_rating",
        "all_version_ratings_count",
        "first_scanned_date",
        "ratings_history",
        "versions_history",
        "bundle_identifier",
        "countries_available_in",
        "taken_down",
        "icon_url",
        "first_scraped",
        "ratings_by_country",
        "user_base_by_country"
      ]

      # List of attributes to pluck from respective collections

      attributes_from_app = [
        "id",
        "released",
        "user_base"
      ]

      newest_ios_app_snapshot_attributes = [
        "id",
        "ios_app_id",
        "seller_url",
        "support_url",
        "seller",
        "description",
        "price",
        "name",
        "released",
        "ratings_all_stars",
        "ratings_all_count",
        "version",
        "ratings_current_count",
        "ratings_current_stars",
        "icon_url_350x350",
        "ratings_per_day_current_release"
      ]

      first_international_snapshot_attributes = [
        "ios_app_id",
        "seller_url",
        "description",
        "price",
        "name",
        "mobile_priority",
        "user_base",
        "app_store_id",
        "bundle_identifier",
        "icon_url_100x100",
        "released",
        "version",
        "ratings_all_stars",
        "ratings_all_count",
        "ratings_current_count",
        "ratings_current_stars",
        "first_released"
      ]

      # Used to generate raw map of app store attributes for quick lookup
      app_store_map_attributes = [
        "id",
        "country_code",
        "name"
      ]

      all_storefront_snapshot_attributes = [
        "ios_app_id",
        "app_store_id",
        "ratings_all_stars",
        "ratings_all_count",
        "ratings_current_stars",
        "ratings_current_count",
        "ratings_per_day_current_release",
        "user_base"
      ]

      snapshot_category_join_attributes = [
        "kind",
        "ios_app_category_id"
      ]

      category_attributes = [
        "name",
        "category_identifier",
        "id"
      ]

      app_store_attributes = [
        "country_code",
        "id",
        "display_priority"
      ]

      publisher_attributes = [
        "name",
        "id",
        "identifier"
      ]

      historical_attributes = [
        "created_at",
        "ios_app_id",
        "ratings_all_count",
        "ratings_all_stars",
        "version",
        "released"
      ]

      sdk_attributes = [
        "id",
        "name",
        "last_seen_date",
        "first_seen_date",
        "activities"
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
        ['version', 'current_version'],
        ['ratings_current_count', 'current_version_ratings_count'],
        ['ratings_current_stars', 'current_version_rating']
      ]

      ##
      # Step 1:
      #
      # Run bulk queries and build out info mappings in memory.
      #

      # Build app_id => us snapshots attributes mapping
      #
      # {
      #   app_id => [
      #     [ app_id, snapshot_id, ios_app_id, seller_url, etc. ]
      #   ]
      # }
      #

      results = {}

      apps = IosApp.where(:id => ids).to_a
      app_ids = apps.map(&:id)

      us_snapshot_attributes = IosAppSnapshot.where(:id => apps.map(&:newest_ios_app_snapshot_id)).pluck(*newest_ios_app_snapshot_attributes)
      us_snapshot_attributes_map = {}
      us_snapshot_attributes.each do |attributes|
        us_snapshot_attributes_map[attributes[newest_ios_app_snapshot_attributes.index("ios_app_id")]] = attributes
      end

      us_snapshot_ids = us_snapshot_attributes.map { |a| a[newest_ios_app_snapshot_attributes.index("id")] }
      snapshot_ids_with_in_app_purchases = IosInAppPurchase.where(:ios_app_snapshot_id => us_snapshot_ids).group(:ios_app_snapshot_id).pluck(:ios_app_snapshot_id)

      us_snapshot_attributes = nil


      snapshots_history_attributes = IosAppSnapshot.where(:ios_app_id => app_ids).pluck(*historical_attributes)
      snapshots_history_attributes_map = {}
      snapshots_history_attributes.each do |snapshot|
        app_id = snapshot[historical_attributes.index("ios_app_id")]
        if snapshots_history_attributes_map[app_id]
          snapshots_history_attributes_map[app_id] << snapshot
        else
          snapshots_history_attributes_map[app_id] = [ snapshot ]
        end
      end
      snapshots_history_attributes = nil


      # Build app_id => storefront details mapping
      #
      # {
      #   app_id => [
      #     [ app_id, country_code, id, display_priority ]
      #   ]
      # }
      #

      app_country_codes_map = {}
      available_store_attributes_to_pluck = [ "ios_apps.id" ] + app_store_attributes.map { |a| "app_stores.#{a}" }
      app_store_results = IosApp.where(:id => ids).joins(:app_stores).pluck(*available_store_attributes_to_pluck).uniq
      app_store_results.each do |app_store_result|
        if app_country_codes_map[app_store_result[0]]
          app_country_codes_map[app_store_result[0]] << app_store_result
        else
          app_country_codes_map[app_store_result[0]] = [ app_store_result ]
        end
      end
      app_store_results = nil


      # Build app_id => storefront snapshot attributes
      #
      # {
      #   app_id => [
      #     [ ios_app_id, app_store_id, ratings_all_stars, ratings_all_count, ratings_current_stars, etc. ]
      #   ]
      # }
      #

      storefront_clauses = []
      app_country_codes_map.each do |app_id, storefront_list|
        storefront_list.each do |storefront_details|
          storefront_clauses << "(ios_app_id = '#{app_id}' and app_store_id = '#{storefront_details[app_store_attributes.index("id")+1]}')" # add 1 to index because first element is ios_app_id
        end
      end

      app_to_storefront_snapshot_attributes = {}
      if storefront_clauses.any?
        storefront_snapshot_results = IosAppCurrentSnapshot.from('ios_app_current_snapshots FORCE INDEX(index_ios_app_current_snapshot_backups_on_ios_app_id_and_latest)').where(:latest => true).where(:ios_app_id => app_ids).where(storefront_clauses.join(" or ")).pluck(*all_storefront_snapshot_attributes)
        storefront_snapshot_results.each do |result|
          app_id = result[all_storefront_snapshot_attributes.index("ios_app_id")]
          if app_to_storefront_snapshot_attributes[app_id]
            app_to_storefront_snapshot_attributes[app_id] << result
          else
            app_to_storefront_snapshot_attributes[app_id] = [ result ]
          end
        end
      end

      # Build app_store_id => store details
      #
      # {
      #   app_store_id => [ app_store_id, country_code, name ]
      # }
      #

      app_store_details_map = {}
      enabled_app_stores_attributes = AppStore.where(:enabled => true).pluck(*app_store_map_attributes)
      enabled_app_stores_attributes.each do |attributes|
        app_store_details_map[attributes[app_store_map_attributes.index("id")]] = attributes
      end

      # Build app_id => first international snapshot details mapping
      #
      # {
      #   app_id => [
      #     [ app_id, ios_app_id, seller_url, etc. ]
      #   ]
      # }
      #

      prefixed_snapshot_attributes = first_international_snapshot_attributes.map { |a| "all_latest_snapshot_attributes.#{a}" }
      first_international_snapshot_attribute_results = ActiveRecord::Base.connection.execute(
      "SELECT #{prefixed_snapshot_attributes.join(",")}
       FROM
         (SELECT ios_app_current_snapshots.ios_app_id,
                 MIN(display_priority) AS dp
          FROM `ios_app_current_snapshots`
          INNER JOIN `app_stores` ON `app_stores`.`id` = `ios_app_current_snapshots`.`app_store_id`
          WHERE `ios_app_current_snapshots`.`latest` = 1
            AND `ios_app_current_snapshots`.`ios_app_id` IN (#{app_ids.join(",")})
          GROUP BY `ios_app_id`) AS ios_app_ids_to_highest_display_priority
       INNER JOIN
         (SELECT ios_app_current_snapshots.*,
                 app_stores.display_priority AS display_priority
          FROM `ios_app_current_snapshots`
          INNER JOIN `app_stores` ON `app_stores`.`id` = `ios_app_current_snapshots`.`app_store_id`
          WHERE `ios_app_current_snapshots`.`latest` = 1
            AND `ios_app_current_snapshots`.`ios_app_id` IN (#{app_ids.join(",")})) AS all_latest_snapshot_attributes ON ios_app_ids_to_highest_display_priority.ios_app_id = all_latest_snapshot_attributes.ios_app_id
       AND ios_app_ids_to_highest_display_priority.dp = all_latest_snapshot_attributes.display_priority")

      first_international_snapshot_attributes_map = {}
      first_international_snapshot_attribute_results.each do |attributes|
        first_international_snapshot_attributes_map[attributes[first_international_snapshot_attributes.index("ios_app_id")]] = attributes
      end

      # Build app_id => newest_snapshot/category mapping
      #
      # {
      #   app_id => [
      #     [ app_id, kind, name, category_id ]
      #   ]
      # }
      #

      prefixed_category_join_attributes = snapshot_category_join_attributes.map { |c| "ios_app_categories_current_snapshots.#{c}" }
      category_attributes_to_pluck = [ "ios_app_current_snapshots.ios_app_id" ] + prefixed_category_join_attributes
      category_results = IosAppCurrentSnapshot.where(:latest => true).where(:ios_app_id => ids).joins(:ios_app_categories_current_snapshots).pluck(*category_attributes_to_pluck).uniq
      kinds_map = IosAppCategoriesCurrentSnapshot.kinds.invert

      # Build intermediate category info mapping instead of using triple join, since triple join only seems to return primary types
      # due to the has_many relationship declared in the IosAppCurrentSnapshots class.
      category_ids = category_results.map { |cra| cra[snapshot_category_join_attributes.index("ios_app_category_id") + 1] }
      category_info_results = IosAppCategory.where(:id => category_ids).pluck(*category_attributes)
      category_info_results_map = {}
      category_info_results.each do |category_info_result|
        category_info_results_map[category_info_result[category_attributes.index("id")]] = category_info_result
      end
      category_info_results = nil

      app_id_to_category_map = {}
      category_results.each do |category_result_attributes|
        kind_index = snapshot_category_join_attributes.index("kind") + 1
        category_result_attributes[kind_index] = kinds_map[category_result_attributes[kind_index]] # Convert the kind enum val to the name
        category_info = category_info_results_map[category_result_attributes[snapshot_category_join_attributes.index("ios_app_category_id") + 1]]
        if category_info
          category_result_attributes << category_info[category_attributes.index("name")]
          category_result_attributes << category_info[category_attributes.index("category_identifier")]
        end
        if app_id_to_category_map[category_result_attributes[0]]
          app_id_to_category_map[category_result_attributes[0]] << category_result_attributes
        else
          app_id_to_category_map[category_result_attributes[0]] = [ category_result_attributes ]
        end
      end

      # Build publisher => publisher details mapping
      #
      # {
      #   publisher_id => {
      #     "app_store_id" => id,
      #     "platform" => platform,
      #     "id" => id,
      #     "name" => name
      #   }
      # }
      #

      developer_id_to_attributes = {}
      ios_developer_attributes = IosDeveloper.where(:id => apps.map(&:ios_developer_id)).pluck(*publisher_attributes)
      ios_developer_attributes.each do |developer_attributes|
        developer_id_to_attributes[developer_attributes[publisher_attributes.index("id")]] = {
          "app_store_id" => developer_attributes[publisher_attributes.index("identifier")],
          "platform" => "ios",
          "id" => developer_attributes[publisher_attributes.index("id")],
          "name" => developer_attributes[publisher_attributes.index("name")]
        }
      end

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

      developer_id_to_website_id = IosDevelopersWebsite.where(:ios_developer_id => developer_id_to_attributes.keys).pluck(:ios_developer_id, :website_id)

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

      user_base_map = IosApp.user_bases.invert
      mobile_priority_map = IosApp.mobile_priorities.invert

      ##
      # Step 2:
      #
      # Build out app exports from mappings generated in first step
      #

      apps.each do |app|
        id = app.id
        result = {
          "countries_available_in" => [],
          "categories" => [],
          "mobile_priority" => "low"
        }

        attributes_from_app.each do |attribute|
          result[attribute] = app.send(attribute).as_json
        end

        result["original_release_date"] = result["released"]
        result.delete("released")

        result["user_base"] = IosApp.user_bases[result["user_base"]]

        us_snapshot_attribute_entry = us_snapshot_attributes_map[id]
        if us_snapshot_attribute_entry
          us_snapshot_attribute_hash = Hash[newest_ios_app_snapshot_attributes.zip(us_snapshot_attribute_entry)]
          us_snapshot_attribute_hash.delete("id")
          result = result.merge(us_snapshot_attribute_hash)

          # Use pre-built maps to determine if app has in in-app purchases
          us_snapshot_id = us_snapshot_attribute_entry[newest_ios_app_snapshot_attributes.index("id")]
          result["has_in_app_purchases"] = snapshot_ids_with_in_app_purchases.include?(us_snapshot_id)
        end

        international_snapshot_attribute_entry = first_international_snapshot_attributes_map[id]
        result = result.merge(Hash[first_international_snapshot_attributes.zip(international_snapshot_attribute_entry)]) if international_snapshot_attribute_entry

        result["mobile_priority"] = IosApp.mobile_priority_from_date(released: result["released"])
        result["last_updated"] = result["released"].as_json
        result.delete("released")

        # Sometimes apps change their original release date on a subsequent release,
        # so overwrite the original_release_date from the IosApp object if the newest
        # ios snapshot has a first_released date.
        if result["first_released"]
          result["original_release_date"] = result["first_released"].iso8601
          result.delete("first_released")
        end

        result["user_base"] = user_base_map[result["user_base"]]

        if app_id_to_category_map[id]
          result["categories"] = app_id_to_category_map[id].map do |category_info|
            {
              "type" => category_info[1 + snapshot_category_join_attributes.index("kind")],
              "name" => category_info[1 + snapshot_category_join_attributes.length + category_attributes.index("name")],
              "id" => category_info[1 + snapshot_category_join_attributes.length + category_attributes.index("category_identifier")]
            }
          end
        end

        if app_country_codes_map[id]
          result["countries_available_in"] = app_country_codes_map[id].map do |storefront_info|
            storefront_info[1 + app_store_attributes.index("country_code")]
          end.uniq
        end

        result["publisher"] = developer_id_to_attributes[app.ios_developer_id] if developer_id_to_attributes[app.ios_developer_id]
        result["taken_down"] = app_country_codes_map[id].nil? || app.display_type == IosApp.display_types[:not_ios]
        result["platform"] = "ios"
        result['app_store_id'] = app.app_identifier

        headquarters = []
        website_ids = developer_id_to_website_id_map[app.ios_developer_id]
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

        # Gather versions, ratings history if any

        historical_snapshots = snapshots_history_attributes_map[app.id]
        if historical_snapshots
          historical_ratings_snapshots = historical_snapshots.map { |s| [s[historical_attributes.index("ratings_all_count")], s[historical_attributes.index("ratings_all_stars")], s[historical_attributes.index("created_at")]] }
          app_ratings_history = app.run_length_encode_app_snapshot_fields_from_fetched(historical_ratings_snapshots, [:ratings_all_count, :ratings_all_stars, :created_at])
          result["ratings_history"] = app_ratings_history.as_json

          app_versions_history = historical_snapshots.map{|s|[s[historical_attributes.index("version")],s[historical_attributes.index("released")]]}.uniq.select{|x| x[0] and x[1]}.map {|x| {version: x[0], released: x[1]}}
          result["versions_history"] = app_versions_history.as_json

          if result['versions_history'] and result['versions_history'].any?
            result['first_scraped'] = result['versions_history'][0]["released"]
          end
        end

        # Calculate aggregate ratings stats across the stores the app is currently available in

        if app_to_storefront_snapshot_attributes[app.id]
          ratings_by_country = []
          user_base_by_country = []
          app_to_storefront_snapshot_attributes[app.id].each do |storefront_snapshot_attributes|
            app_store_id = storefront_snapshot_attributes[all_storefront_snapshot_attributes.index("app_store_id")]
            ratings_by_country << {
              "current_rating" =>  storefront_snapshot_attributes[all_storefront_snapshot_attributes.index("ratings_current_stars")].to_f,
              "ratings_current_count" => storefront_snapshot_attributes[all_storefront_snapshot_attributes.index("ratings_current_count")],
              "ratings_per_day_current_release" => storefront_snapshot_attributes[all_storefront_snapshot_attributes.index("ratings_per_day_current_release")].to_f,
              "country_code" => app_store_details_map[app_store_id][app_store_map_attributes.index("country_code")],
              "rating" => storefront_snapshot_attributes[all_storefront_snapshot_attributes.index("ratings_all_stars")].to_f,
              "ratings_count" => storefront_snapshot_attributes[all_storefront_snapshot_attributes.index("ratings_all_count")],
              "country" => app_store_details_map[app_store_id][app_store_map_attributes.index("name")]
            }

            user_base_by_country << {
              "country_code" => app_store_details_map[app_store_id][app_store_map_attributes.index("country_code")],
              "country" => app_store_details_map[app_store_id][app_store_map_attributes.index("name")],
              "user_base" => user_base_map[storefront_snapshot_attributes[all_storefront_snapshot_attributes.index("user_base")]]
            }
          end
          result["ratings_by_country"] = ratings_by_country
          result["user_base_by_country"] = user_base_by_country
        elsif us_snapshot_attributes_map[app.id]
          result["ratings_by_country"] = [
            {
              "current_rating" => us_snapshot_attributes_map[app.id][newest_ios_app_snapshot_attributes.index("ratings_current_stars")].to_f,
              "ratings_current_count" => us_snapshot_attributes_map[app.id][newest_ios_app_snapshot_attributes.index("ratings_current_count")],
              "ratings_per_day_current_release" => us_snapshot_attributes_map[app.id][newest_ios_app_snapshot_attributes.index("ratings_per_day_current_release")].to_f,
              "country_code" => "US",
              "rating" => us_snapshot_attributes_map[app.id][newest_ios_app_snapshot_attributes.index("ratings_all_stars")].to_f,
              "ratings_count" => us_snapshot_attributes_map[app.id][newest_ios_app_snapshot_attributes.index("ratings_all_count")],
              "country" => "United States"
            }
          ]
        end

        if result["ratings_by_country"]
          ratings_details = result["ratings_by_country"]

          all_ratings_count = ratings_details.map { |storefront_rating|
            storefront_rating["ratings_count"]
          }.compact.inject(0, &:+) # sums all the ratings_counts in list

          result["all_version_ratings_count"] = all_ratings_count
          result["all_version_rating"] = 0

          if all_ratings_count != nil and all_ratings_count > 0
            storefront_ratings_average = 0
            ratings_details.each do |storefront_rating|
              ratings_count = storefront_rating["ratings_count"]
              rating_stars = storefront_rating["rating"]
              next if ratings_count.nil? or rating_stars.nil?

              weight = ratings_count.to_f / all_ratings_count
              storefront_ratings_average = storefront_ratings_average + ( weight * rating_stars )
            end

            result["all_version_rating"] = storefront_ratings_average
          end
        end

        results[id] = result
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

        sdks_to_tags_tuples = IosSdk.where(:id => sdk_ids.to_a).joins(:tags).pluck("ios_sdks.id", "tags.name")

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

      ad_stats = IosFbAd.where(:ios_app_id => app_ids).select('ios_app_id, min(date_seen) as created_at, max(date_seen) as updated_at').group(:ios_app_id)
      ad_stats.each do |ad_stat|
        if results[ad_stat.ios_app_id]
          results[ad_stat.ios_app_id]["first_seen_ads_date"] = ad_stat.created_at
          results[ad_stat.ios_app_id]["last_seen_ads_date"] = ad_stat.updated_at
          results[ad_stat.ios_app_id]["has_ad_spend"] = true
        else
          Bugsnag.notify(RuntimeError.new("Missing app snapshot entry for #{ad_stat.ios_app_id}"))
        end
      end

      app_missing_ads = app_ids - ad_stats.map(&:ios_app_id)
      app_missing_ads.each do |app_id|
        if results[app_id]
          results[app_id]['has_ad_spend'] = false
        else
          Bugsnag.notify(RuntimeError.new("Missing app snapshot entry for #{app_id}"))
        end
      end

      scan_statuses = IpaSnapshot.where(scan_status: IpaSnapshot.scan_statuses[:scanned]).where(:ios_app_id => app_ids)
        .group(:ios_app_id).select('ios_app_id', 'max(good_as_of_date) as last_scanned', 'min(good_as_of_date) as created_at')

      scan_statuses.each do |scan_status|
        if results[scan_status.ios_app_id]
          results[scan_status.ios_app_id]["first_scanned_date"] = scan_status.created_at.utc.iso8601
          results[scan_status.ios_app_id]["last_scanned_date"] = scan_status.last_scanned.utc.iso8601
        else
          Bugsnag.notify(RuntimeError.new("Missing app snapshot entry for #{scan_status.ios_app_id}"))
        end
      end

      results.values.each do |app|
        rename.map do |field, new_name|
          app[new_name] = app[field]
          app.delete(field)
        end

        if app["icon_url_100x100"]
          app["icon_url"] = IosApp.convert_icon_url_to_https(app["icon_url_100x100"])
          app.delete("icon_url_100x100")
        elsif app["icon_url_350x350"]
          app["icon_url"] = IosApp.convert_icon_url_to_https(app["icon_url_350x350"])
          app.delete("icon_url_350x350")
        end
      end

      results.each do |app_id, result|
        results[app_id] = result.slice(*attribute_whitelist)
      end

      results

  end

  def as_external_dump_json(extra_white_list: [], extra_from_app: [], extra_sdk_fields: [], extra_publisher_fields: [], include_sdk_history: true)
      app = self

      # Only these attributes will be output in the final response.
      white_list = [
          'last_seen_ads_date', 'last_updated',
          'seller_url',
          'current_version', 'has_in_app_purchases',
          'id', 'first_seen_ads_date', 'platform',
          'support_url', 'seller',
          'original_release_date',
          'uninstalled_sdks', 'all_version_rating',
          'description', 'price',
          'has_ad_spend',
          'categories', 'name', 'installed_sdks',
          'publisher', 'content_rating',
          'mobile_priority',
          'user_base', 'app_store_id', 'last_scanned_date',
          'current_version_ratings_count',
          'current_version_rating', 'all_version_ratings_count',
          'first_scanned_date',
          'ratings_history', 'versions_history', 'bundle_identifier',
          'countries_available_in',
          'taken_down',
          'icon_url',
          'first_scraped'
          ] + extra_white_list + extra_from_app

      rename = [
          ['ratings_all_stars', 'all_version_rating'],
          ['ratings_all_count', 'all_version_ratings_count'],
          ['version', 'current_version'],
          ['app_identifier', 'app_store_id'],
          ['ratings_current_count', 'current_version_ratings_count'],
          ['ratings_current_stars', 'current_version_rating']
          ]

      fields_from_app = [
          ['mobile_priority', 'mobile_priority'],
          ['id', 'id'],
          ['user_base', 'user_base'],
          ['last_updated', 'last_updated'],
          ['released', 'original_release_date'], # This "released" that comes from IosApp is original version release
          ['ratings_history', 'ratings_history'],
          ['versions_history', 'versions_history'],
          ['icon_url', 'icon_url']
          ] + (extra_from_app.map { |field| [ field, field ] })

      sdk_fields = [
          "id",
          "name",
          "last_seen_date",
          "first_seen_date"
          ] + extra_sdk_fields

      publisher_fields = [
          "name",
          "id",
          "identifier"
          ] + extra_publisher_fields

      app_obj = app.newest_ios_app_snapshot.as_json || {}
      app_obj.merge!(app.first_international_snapshot.as_json || {})

      app_obj['mightysignal_app_version'] = '1'

      if include_sdk_history
        app_obj.merge!(app.sdk_history)
        app_obj["installed_sdks"] = app_obj[:installed_sdks].map{|sdk| sdk.slice(*sdk_fields)}
        app_obj["installed_sdks"].map do |sdk|
          sdk["categories"] = IosSdk.find(sdk["id"]).tags.pluck(:name)
        end
        app_obj["uninstalled_sdks"] = app_obj[:uninstalled_sdks].map{|sdk| sdk.slice(*(sdk_fields + ["first_unseen_date"]))}
        app_obj["uninstalled_sdks"].map do |sdk|
          sdk["categories"] = IosSdk.find(sdk["id"]).tags.pluck(:name)
        end
      end

      app_obj["categories"] = IosSnapshotAccessor.new.categories_from_ios_app(self, with_category_id: true)
      app_obj["countries_available_in"] = app.app_stores.pluck(:country_code)

      if app.ios_developer
        app_obj['publisher'] = app.ios_developer.as_json.slice(*publisher_fields)
        app_obj['publisher']['app_store_id'] = app_obj['publisher']["identifier"]
        app_obj['publisher'].delete("identifier")
        app_obj['publisher']['platform'] = platform
      end

      app_obj["platform"] = platform
      if app.newest_ios_app_snapshot
        app_obj["has_in_app_purchases"] = app.newest_ios_app_snapshot.ios_in_app_purchases.any?
      end

      fields_from_app.map do |field, new_name|
          app_obj[new_name] = app.send(field).as_json
      end

      rename.map do |field, new_name|
          app_obj[new_name] = app_obj[field]
          app_obj.delete(field)
      end

      if app_obj['versions_history'] and app_obj['versions_history'].any?
        app_obj['first_scraped'] = app_obj['versions_history'][0]["released"]
      end

      # Overwrite original_release_date from the snapshot first_released attribute
      # since apps can change their original release date.
      app_obj['original_release_date'] = app_obj['first_released'] if app_obj['first_released']

      app_obj['last_seen_ads_date'] = app.last_seen_ads_date
      app_obj['first_seen_ads_date'] = app.first_seen_ads_date

      app_obj['has_ad_spend'] = app.ios_fb_ads.any?
      app_obj['taken_down'] = !app.app_store_available
      app_obj['app_store_id'] = app.app_identifier

      data = app.ipa_snapshots.where(scan_status: IpaSnapshot.scan_statuses[:scanned]).
      group(:ios_app_id).select('ios_app_id', 'max(good_as_of_date) as last_scanned', 'min(good_as_of_date) as first_scanned')
      if data[0]
        app_obj["first_scanned_date"] = data[0].first_scanned.utc.iso8601
        app_obj["last_scanned_date"] = data[0].last_scanned.utc.iso8601
      end
      app_obj.slice(*white_list)
  end

  def api_json(options = {})
    result = {
      id: id,
      platform: :ios,
      app_store_id: app_identifier,
      original_release_date: released,
      mobile_priority: mobile_priority,
      user_base: user_base,
      has_ad_spend: ad_spend?,
      bundle_identifier: nil # set default
    }
    result[:publisher] = ios_developer.present? ? ios_developer.api_json(short_form: true) : nil
    data = es_info
    if data != NoESData
      result.merge!(
       first_scanned_date: data['first_scanned'],
        last_scanned_date: data['last_scanned'],
        first_seen_ads_date: data['first_seen_ads'],
        last_seen_ads_date: data['last_seen_ads']
      )
    end
    result[:taken_down] = !app_store_available
    result.merge!(newest_ios_app_snapshot.try(:api_json) || {})
    result.merge!(api_international_hash(first_international_snapshot) || {})
    result.merge!(sdk_json || {}) unless options[:short_form]
    result
  end

  def sdk_json
    data = es_info
    if data == NoESData
      installed = uninstalled = []
    else
      installed = data.fetch('installed_sdks') || []
      uninstalled = data.fetch('uninstalled_sdks') || []
    end
    combined = [installed, uninstalled].map do |es_sdks|
      hydrated_sdks = IosSdk.where(id: es_sdks.map { |x| x['id'] }).map { |s| s.api_json(short_form: true) }
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

  def es_info
    result = es_client.query(
      term: { 'id' => id }
    ).first
    result.present? ? result.attributes : NoESData
  end


  # handles key conversions for public facing API
  def api_international_hash(int_hash)
    return {} if int_hash.blank?
    {
      name: int_hash['name'],
      last_updated: int_hash['released'].to_s,
      seller: int_hash['seller_name'],
      description: int_hash['description'],
      price: int_hash['price'] ? int_hash['price'] / 100.0 : nil, # convert cents to dollars
      current_version: int_hash['version'],
      current_version_rating: int_hash['ratings_current_stars'],
      current_version_ratings_count: int_hash['ratings_current_count'],
      all_version_rating: int_hash['ratings_all_stars'],
      all_version_ratings_count: int_hash['ratings_all_count'],
      categories: int_hash['categories_snapshots'].as_json,
      user_base: int_hash['user_base'],
      bundle_identifier: int_hash['bundle_identifier']
    }
  end

  class << self

    def convert_icon_url_to_https(url)
      url.gsub(/http:\/\/is([0-9]+).mzstatic/, 'https://is\1-ssl.mzstatic') if url.present?
    end

    def mobile_priority_from_date(released: nil)
      if released
          if released > 2.months.ago
            return 'high'
          elsif released > 4.months.ago
            return 'medium'
          else
            return 'low'
          end
      end
      'low'
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
