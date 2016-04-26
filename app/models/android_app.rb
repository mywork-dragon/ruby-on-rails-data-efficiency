class AndroidApp < ActiveRecord::Base

  validates :app_identifier, uniqueness: true
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

  has_many :sdk_js_tags

  has_many :apk_snapshot_scrape_failures
  has_many :apk_snapshot_jobs
  has_many :apk_snapshot_scrape_exceptions
  has_many :weekly_batches, as: :owner
  has_many :follow_relationships
  has_many :followers, as: :followable, through: :follow_relationships

  enum mobile_priority: [:high, :medium, :low]
  enum user_base: [:elite, :strong, :moderate, :weak]

  enum display_type: [:normal, :taken_down, :foreign, :device_incompatible, :carrier_incompatible, :item_not_found]
  
  def get_newest_app_snapshot
    self.android_app_snapshots.max_by do |snapshot|
      snapshot.created_at
    end
  end
  
  def get_website_urls
    self.websites.map{|w| w.url}
  end
  
  def get_company
    self.websites.each do |w|
      if w.company.present?
        return w.company
      end
    end
    return nil
  end
  
  def name
    if newest_android_app_snapshot.present?
      return newest_android_app_snapshot.name
    else
      return nil
    end
  end

  def as_json(options={})
    company = self.get_company
    newest_snapshot = self.newest_android_app_snapshot

    batch_json = {
      id: self.id,
      type: self.class.name,
      name: newest_snapshot.try(:name),
      platform: 'android',
      mobilePriority: self.mobile_priority,
      adSpend: self.old_ad_spend?,
      lastUpdated: newest_snapshot.try(:released),
      lastUpdatedDays: self.last_updated_days,
      categories: self.categories,
      seller: newest_snapshot.try(:seller),
      supportDesk: newest_snapshot.try(:seller_url),
      userBase: self.user_base,
      icon: newest_snapshot.try(:icon_url_300x300),
      downloadsMin: newest_snapshot.try(:downloads_min),
      downloadsMax: newest_snapshot.try(:downloads_max),
      price: newest_snapshot.try(:price),
      company: company,
      publisher: {
        id: self.try(:android_developer).try(:id),
        name: self.try(:android_developer).try(:name),
        websites: self.try(:android_developer).try(:get_website_urls)
      },
    }

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
      })
    end

    if options[:user]
      batch_json[:following] = options[:user].following?(self) 
    end
    batch_json
  end

  def link(stage: :production)
    if stage == :production
      "http://mightysignal.com/app/app#/app/android/#{id}"
    elsif stage == :staging
      "http://ms-staging.com/app/app#/app/android/#{id}"
    end
  end

  def get_newest_apk_snapshot
    self.apk_snapshots.where(scan_status: 1).first
  end

  def last_updated_days
    if released = self.newest_android_app_snapshot.try(:released)
      (Time.now.to_date - released.to_date).to_i
    end
  end

  def categories
    if newest_snapshot = self.newest_android_app_snapshot
      newest_snapshot.android_app_categories.map{|c| c.name}
    end
  end

  def old_ad_spend?
    self.android_fb_ad_appearances.present?
  end

  def downloads
    if newest_snapshot = self.newest_android_app_snapshot
      "#{newest_snapshot.downloads_min}-#{newest_snapshot.downloads_max}"
    end
  end

  def installed_sdks
    newest_snap = self.apk_snapshots.where(status: 1, scan_status: 1).last
    return nil if newest_snap.blank?
    newest_sdks = newest_snap.android_sdks
    sdk_apk = newest_sdks.map{|x| [x.id, newest_snap.id] }
    get_sdks(sdk_apk, :first_seen)
  end

  def uninstalled_sdks
    newest_snap = self.apk_snapshots.where(status: 1, scan_status: 1).last
    return nil if newest_snap.blank?
    newest_sdks = newest_snap.android_sdks
    snaps = self.apk_snapshots.where.not(id: newest_snap.id).map(&:id)
    sdk_apk = AndroidSdksApkSnapshot.where(apk_snapshot_id: snaps).where.not(android_sdk_id: newest_sdks).map{|x| [x.android_sdk_id, x.apk_snapshot_id] }
    get_sdks(sdk_apk, :last_seen)
  end

  def icon_url(size='300x300') # size should be string eg '350x350'
    if newest_android_app_snapshot.present?
      return newest_android_app_snapshot.send("icon_url_#{size}")
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
