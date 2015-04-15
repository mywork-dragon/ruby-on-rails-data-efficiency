class AndroidApp < ActiveRecord::Base

  validates :app_identifier, uniqueness: true
  belongs_to :app
  
  has_many :android_app_snapshots
  # has_many :websites, through: :android_apps_snapshots
  has_many :android_apps_websites
  has_many :websites, through: :android_apps_websites

  belongs_to :newest_android_app_snapshot, class_name: 'AndroidAppSnapshot', foreign_key: 'newest_android_app_snapshot_id'  
  after_update :set_user_base, if: :newest_android_app_snapshot_id_changed?
  
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
  
  ###############################
  # Mobile priority methods
  ###############################
  
  def set_mobile_priority
    begin
      if fb_ad_appearances.present? || newest_android_app_snapshot.released > 3.months.ago
        set_mobile_priority_high
      elsif newest_android_app_snapshot.released > 6.months.ago
        set_mobile_priority_moderate
      else
        set_mobile_priority_low
      end
    rescue Exception => e
      logger.info "Warning: couldn't update mobile priority for AndroidApp with ID #{self.id}"
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
  end
  
  ########################
  # User Base methods       
  ########################
  
  def set_user_base
    logger.info puts "updating user base"
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
      logger.info "Warning: couldn't update user base for AndroidApp with ID #{self.id}"
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
