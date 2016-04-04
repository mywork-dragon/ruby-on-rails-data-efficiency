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

  def platform
    'android'
  end

  def get_newest_apk_snapshot
    self.apk_snapshots.where(scan_status: 1).first
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
