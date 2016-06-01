class IosApp < ActiveRecord::Base

  validates :app_identifier, uniqueness: true
  # validates :app_stores, presence: true #can't have an IosApp if it's not connected to an App Store

  has_many :ipa_snapshot_job_exceptions
  has_many :ios_app_snapshots
  belongs_to :app
  has_many :ios_fb_ad_appearances
  has_many :ios_app_download_snapshots
  has_many :ipa_snapshots
  has_many :ipa_snapshot_lookup_failures
  
  has_many :ios_apps_websites  
  has_many :websites, through: :ios_apps_websites

  has_many :listables_lists, as: :listable
  has_many :lists, through: :listables_lists
  
  belongs_to :newest_ios_app_snapshot, class_name: 'IosAppSnapshot', foreign_key: 'newest_ios_app_snapshot_id'
  belongs_to :newest_ipa_snapshot, class_name: 'IpaSnapshot', foreign_key: 'newest_ipa_snapshot_id'
  
  has_many :app_stores_ios_apps
  has_many :app_stores, -> { uniq }, through: :app_stores_ios_apps
  
  belongs_to :ios_developer

  has_many :weekly_batches, as: :owner
  has_many :follow_relationships
  has_many :followers, as: :followable, through: :follow_relationships
  has_many :ios_fb_ads

  has_many :ios_app_rankings
  
  enum mobile_priority: [:high, :medium, :low]
  enum user_base: [:elite, :strong, :moderate, :weak]
  enum display_type: [:normal, :taken_down, :foreign, :device_incompatible, :paid, :not_ios]

  update_index('apps#ios_app') { self } if Rails.env.production?
  
  WHITELISTED_APPS = [404249815,297606951,447188370,368677368,324684580,477128284,
                      529479190, 547702041,591981144,618783545,317469184,401626263]

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

  def as_json(options={})
    company = self.get_company
    newest_snapshot = self.newest_ios_app_snapshot
    
    batch_json = {
      id: self.id,
      type: self.class.name,
      platform: 'ios',
      releaseDate: newest_snapshot.try(:released),
      name: self.name,
      mobilePriority: self.mobile_priority,
      userBase: self.user_base,
      releasedDays: self.released,
      lastUpdated: self.last_updated,
      lastUpdatedDays: self.last_updated_days,
      seller: self.seller,
      supportDesk: self.support_url,
      categories: self.categories,
      icon: self.icon_url,
      adSpend: self.old_ad_spend?,
      price: newest_snapshot.try(:price),
      publisher: {
        id: self.try(:ios_developer).try(:id),
        name: self.try(:ios_developer).try(:name),
        websites: self.try(:ios_developer).try(:get_website_urls)
      },
      company: company
    }

    if options[:details]
      batch_json.merge!({
        currentVersion: newest_snapshot.try(:version),
        currentVersionDescription: newest_snapshot.try(:release_notes),
        rating: newest_snapshot.try(:ratings_all_stars),
        ratingsCount: newest_snapshot.try(:ratings_all_count),
        inAppPurchases: newest_snapshot.try(:ios_in_app_purchases).try(:any?),
        appIdentifier: self.app_identifier,
        appStoreId: newest_snapshot.try(:developer_app_store_identifier),
        size: newest_snapshot.try(:size),
        requiredIosVersion: newest_snapshot.try(:required_ios_version),
        recommendedAge: newest_snapshot.try(:recommended_age),
        description: newest_snapshot.try(:description),
        facebookAds: self.ios_fb_ads.has_image
      })
    end
    
    if options[:user]
      batch_json[:following] = options[:user].following?(self) 
      batch_json[:adSpend] = options[:user].account.can_view_ad_spend? ? self.ad_spend? : self.old_ad_spend?
    end
    batch_json
  end

  def categories
    if self.newest_ios_app_snapshot
      IosAppCategoriesSnapshot.where(ios_app_snapshot: self.newest_ios_app_snapshot, kind: IosAppCategoriesSnapshot.kinds[:primary]).map{|iacs| iacs.ios_app_category.name}
    end
  end

  def old_ad_spend?
    self.ios_fb_ad_appearances.any?
  end

  def ad_spend?
    self.ios_fb_ads.any?
  end

  def support_url
    self.newest_ios_app_snapshot.try(:support_url)
  end
  
  def get_website_urls
    self.websites.to_a.map{|w| w.url}
  end

  def seller
    self.newest_ios_app_snapshot.try(:seller)
  end

  def last_updated
    self.newest_ios_app_snapshot.try(:released).try(:to_s)
  end

  def last_updated_days
    if released = self.newest_ios_app_snapshot.try(:released)
      (Time.now.to_date - released.to_date).to_i
    end
  end

  def website
    self.get_website_urls.first
  end

  def icon_url(size='350x350') # size should be string eg '350x350'
    if newest_ios_app_snapshot.present?
      return newest_ios_app_snapshot.send("icon_url_#{size}")
    end
  end

  def sdk_response
    IosSdkService.get_sdk_response(self.id)
  end

  def installed_sdks
    self.sdk_response[:installed_sdks]
  end

  def uninstalled_sdks
    self.sdk_response[:uninstalled_sdks]
  end

  def fortune_rank
    self.get_company.try(:fortune_1000_rank)
  end
  
  def name
    if newest_ios_app_snapshot.present?
      return newest_ios_app_snapshot.name
    end
  end

  def price
    if newest_ios_app_snapshot.present?
      (newest_ios_app_snapshot.price.to_i > 0) ? "$#{newest_ios_app_snapshot.price}" : 'Free' 
    end
  end

  def to_csv_row(can_view_support_desk=false)
    # li "CREATING HASH FOR #{app.id}"
    company = self.get_company
    developer = self.ios_developer
    newest_snapshot = self.newest_ios_app_snapshot

    [
      self.id,
      newest_snapshot.try(:name),
      'IosApp',
      self.mobile_priority,
      self.user_base,
      self.last_updated,
      self.ios_fb_ads.any?,
      self.categories.try(:join, ", "),
      developer.try(:id),
      developer.try(:name),
      developer.try(:identifier),
      company.try(:fortune_1000_rank),
      developer.try(:get_website_urls).try(:join, ', '),
      'http://www.mightysignal.com/app/app#/app/ios/' + self.id.to_s,
      developer.present? ? 'http://www.mightysignal.com/app/app#/publisher/ios/' + developer.id.to_s : nil,
      can_view_support_desk && newest_snapshot.present? ? newest_snapshot.support_url : nil
    ].to_csv
  end
  
  ###############################
  # Mobile priority methods
  ###############################
  
  def set_mobile_priority
    begin
      if ios_fb_ad_appearances.present? || newest_ios_app_snapshot.released > 2.months.ago
        self.mobile_priority = :high
      elsif newest_ios_app_snapshot.released > 4.months.ago
        self.mobile_priority = :medium
      else
        self.mobile_priority = :low
      end
      self.save
    rescue => e
      logger.info "Warning: couldn't update mobile priority for IosApp with id #{self.id}"
      logger.info e
    end
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

  def link(stage: :production)
    if stage == :production
      "http://mightysignal.com/app/app#/app/ios/#{id}"
    elsif stage == :staging
      "http://ms-staging.com/app/app#/app/ios/#{id}"
    end
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
