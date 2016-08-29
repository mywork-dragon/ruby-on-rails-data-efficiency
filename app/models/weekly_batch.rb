class WeeklyBatch < ActiveRecord::Base
  validates :activity_type, presence: true
  
  has_many :weekly_batches_activities
  has_many :activities, through: :weekly_batches_activities

  belongs_to :owner, polymorphic: true

  enum activity_type: [:install, :uninstall, :ad_seen, :entered_top_apps]

  def as_json(options={})
    batch_json = {
      id: self.id,
      page: options[:page] || 1,
      pageSize: self.page_size,
      activity_type: self.activity_type,
      activities_count: self.activities.count,
      owner: self.owner
    }
    batch_json[:apps_count] = self.joined_activities.pluck(:ios_app_id).uniq.count if self.owner_type == 'AdPlatform'
    batch_json
  end

  def page_size
    case self.owner_type
    when 'IosSdk', 'AndroidSdk'
      10
    when 'AndroidApp', 'IosApp'
      20
    when 'AdPlatform'
      10
    end
  end

  def other_owner
    self.activities.first.other_owner(self.owner)
  end

  def opposite_type
    if self.owner_type == 'IosSdk' || self.owner_type == 'AndroidSdk'
      self.owner_type.chomp('Sdk') + 'App'
    elsif self.owner_type == 'IosApp' || self.owner_type == 'AndroidApp'
      self.owner_type.chomp('App') + 'Sdk'
    else
      'IosFbAd'
    end
  end

  def joined_activities
    opposite_class = self.opposite_type.constantize
    activities = self.activities.joins('INNER JOIN weekly_batches_activities wb on wb.activity_id = activities.id').
                                      joins('INNER JOIN weekly_batches on weekly_batches.id = wb.weekly_batch_id').
                                      joins("INNER JOIN #{opposite_class.table_name} op on op.id = weekly_batches.owner_id and weekly_batches.owner_type = '#{opposite_type}'")
    activities = activities.joins("LEFT JOIN ios_sdk_links on ios_sdk_links.source_sdk_id = op.id").where("ios_sdk_links.id is null") if opposite_type == 'IosSdk' 
    activities = activities.joins("LEFT JOIN android_sdk_links on android_sdk_links.source_sdk_id = op.id").where("android_sdk_links.id is null") if opposite_type == 'AndroidSdk'
    activities
  end

  def sorted_activities(page_num=nil, per_page=nil)
    activities = self.joined_activities
    if self.owner_type == 'AdPlatform'
      activities = activities.group(:ios_app_id).select("count(ios_app_id) as impression_count, max(happened_at) as happened_at, activities.id")
          .order("impression_count DESC")
      activities = activities.limit(per_page).offset((page_num - 1) * per_page) if page_num && per_page
    elsif self.owner_type == 'IosSdk' || self.owner_type == 'AndroidSdk'
      activities = activities.order("op.user_base ASC")
      activities = activities.limit(per_page).offset((page_num - 1) * per_page) if page_num && per_page
    else
      activities = activities.select("activities.*, op.flagged, op.favicon, op.name").order("op.name ASC")
      activities = IosSdkService.partition_sdks(ios_sdks: activities)
      activities = activities[((page_num - 1) * per_page), per_page] if page_num && per_page
    end
    activities
  end
end
