class IosApp < ActiveRecord::Base

  validates :app_identifier, uniqueness: true

  has_many :ios_app_snapshots
  belongs_to :app
  has_many :fb_ad_appearances
  has_many :ios_app_download_snapshots
  has_many :ios_apps_websites  
  has_many :websites, through: :ios_apps_websites
  
  belongs_to :newest_ios_app_snapshot, class_name: 'IosAppSnapshot', foreign_key: 'newest_ios_app_snapshot_id'
  after_update :set_user_base, if: :newest_android_app_snapshot_id_changed?
  
  
  def get_newest_app_snapshot
    self.ios_app_snapshots.max_by do |snapshot|
      snapshot.created_at
    end
  end
  
  def get_newest_download_snapshot
    self.ios_app_download_snapshots.max_by do |snapshot|
      snapshot.updated_at
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
  
  def get_website_urls
    self.websites.to_a.map{|w| w.url}
  end
  
  def name
    ios_app_snapshots.last.name
  end
  
  ###############################
  # Mobile priority methods
  ###############################
  
  def set_mobile_priority
    begin
      if fb_ad_appearances.present? || newest_ios_app_snapshot.released > 3.months.ago
        set_mobile_priority_high
      elsif newest_ios_app_snapshot.released > 6.months.ago
        set_mobile_priority_moderate
      else
        set_mobile_priority_low
      end
    rescue Exception => e
      logger.info "Warning: couldn't update mobile priority for IosApp with id #{self.id}"
      logger.info e
    end
  end
  
  def set_mobile_priority_high
    self.mobile_priority = 'high'
    self.save
  end
  
  def set_mobile_priority_medium
    self.mobile_priority = 'medium'
    self.save
  end
  
  def set_mobile_priority_low
    self.mobile_priority = 'low'
    self.save
  end
  
  def mobile_priority_high?
    self.mobile_priority == 'high'
  end
  
  def mobile_priority_medium?
    self.mobile_priority == 'medium'
  end
  
  def mobile_priority_low?
    self.mobile_priority == 'low'
  
  
  ########################
  # User Base methods       
  ########################
  
  def set_user_base
    begin
      if newest_ios_app_snapshot.ratings_per_day_current_release >= 7 || newest_ios_app_snapshot.ratings_all_count >= 50e3
        set_user_base_elite
      elsif newest_ios_app_snapshot.ratings_per_day_current_release >= 1 || newest_ios_app_snapshot.ratings_all_count >= 10e3
        set_user_base_strong
      elsif newest_ios_app_snapshot.ratings_per_day_current_release >= 0.1 || newest_ios_app_snapshot.ratings_all_count >= 100
        set_user_base_moderate
      else
        set_user_base_weak
      end
    rescue Exception => e
      logger.info "Warning: couldn't update user_base for IosApp with id #{self.id}"
      logger.info e
    end
  end
  
  def set_user_base_elite
    self.user_base = "elite"
    self.save
  end
  
  def set_user_base_strong
    self.user_base = "strong"
    self.save
  end
  
  def set_user_base_moderate
    self.user_base = "moderate"
    self.save
  end
  
  def set_user_base_weak
    self.user_base = "weak"
    self.save
  end
  
  def user_base_elite?
    self.user_base == "elite"
  end
  
  def user_base_strong?
    self.user_base == 'strong'
  end
  
  def user_base_moderate?
    self.user_base == 'moderate'
  end
  
  def user_base_weak?
    self.user_base == 'weak'
  end
  
  ########################
  # End user base methods       
  ########################
  
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
