class WeeklyBatch < ActiveRecord::Base
  validates :activity_type, presence: true

  has_many :weekly_batches_activities
  has_many :activities, through: :weekly_batches_activities

  belongs_to :owner, polymorphic: true

  enum activity_type: [:install, :uninstall, :ad_seen, :entered_top_apps]

  def clear_cache
    # Compensate for the slowness of delete_matched.
    # Idk why it's slow but it's not the keys call.
    # This was making a 1-3 second job take 1-3 minutes,
    # while the direct redis calls don't effect performance.
    prefix_to_delete = "weekly_batch:as_json:#{self.id}:*"
    prefix = Rails.application.config.cache_prefix[:namespace]
    keys_to_delete = Rails.cache.data.keys("#{prefix}:#{prefix_to_delete}").map {|x| "#{prefix}:#{x}" }
    keys_to_delete.map {|key| Rails.cache.data.del(key)}
  end

  def _as_json(options)
    batch_json = {
      id: self.id,
      page: options[:page] || 1,
      pageSize: self.page_size,
      activity_type: self.activity_type,
      owner: self.owner
    }
    if options[:country_codes] && is_sdk?
      batch_json[:activities_count] = self.sorted_activities(country_codes: options[:country_codes]).try(:count).try(:size)
    end

    if is_sdk?
      batch_json[:major_activities] = major_activities
    end

    batch_json[:activities_count] ||= is_app? ? self.sorted_activities.count : self.activities.count
    batch_json[:apps_count] = self.joined_activities.pluck(:ios_app_id).uniq.count if is_ad_platform?
    JSON.parse batch_json.to_json
  end

  def as_json(options={})
    option_sha1 = Digest::SHA1.hexdigest(options.to_json)
    key = "weekly_batch:as_json:#{self.id}:#{option_sha1}"
    if Date.today - self.week > 1.weeks
      expire_time = 24.hours
    else
      expire_time = 60.minutes
    end
    Rails.cache.fetch(key, expires: expire_time, compress: true) do
      _as_json(options)
    end
  end

  def is_ios?
    owner_type == 'IosSdk' || owner_type == 'IosApp' || owner_type == 'AdPlatform'
  end

  def is_android?
    owner_type == 'AndroidSdk' || owner_type == 'AndroidApp'
  end

  def is_sdk?
    owner_type == 'IosSdk' || owner_type == 'AndroidSdk'
  end

  def is_app?
    owner_type == 'IosApp' || owner_type == 'AndroidApp'
  end

  def is_ad_platform?
    owner_type == 'AdPlatform'
  end

  def major_activities
    major_activities = self.activities.where(major_app: true).map do |activity|
      {
        app: activity.other_owner(self.owner),
        happened_at: activity.happened_at
      }
    end.sort_by { |activity|
      if is_ios?
        IosApp.user_bases[activity[:app].international_userbase[:user_base]] || 3
      else
        activity[:app][:user_base] || 3
      end
    }.take(10)
  end

  def platform
    if is_android?
      'android'
    elsif is_ios?
      'ios'
    else
      'other'
    end
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
    if is_sdk?
      self.owner_type.chomp('Sdk') + 'App'
    elsif is_app?
      self.owner_type.chomp('App') + 'Sdk'
    else
      'IosFbAd'
    end
  end

  def opposite_developer_type
    if is_sdk?
      self.owner_type.chomp('Sdk') + 'Developer'
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

  def sorted_activities(page_num: nil, per_page: nil, country_codes: nil)
    activities = self.joined_activities
    if is_ad_platform?
      activities = activities.group(:ios_app_id).select("count(ios_app_id) as impression_count, max(happened_at) as happened_at, activities.id")
          .order("impression_count DESC")
      activities = activities.limit(per_page).offset((page_num - 1) * per_page) if page_num && per_page
    elsif is_sdk?
      if country_codes
        activities = activities.joins("INNER JOIN #{opposite_developer_type.underscore}s op_dev on op_dev.id = op.#{opposite_developer_type.underscore}_id").
                                joins("INNER JOIN #{opposite_developer_type.underscore}s_websites web_dev on web_dev.#{opposite_developer_type.underscore}_id = op_dev.id").
                                joins("INNER JOIN websites on websites.id = web_dev.website_id").
                                joins("INNER JOIN websites_domain_data web_dd on web_dd.website_id = websites.id").
                                joins("INNER JOIN domain_data dd on dd.id = web_dd.domain_datum_id").
                                where("web_dev.is_valid" => true, "dd.country_code" => country_codes).
                                group('activities.id')
      end
      activities = activities.order("op.user_base IS NULL, op.user_base ASC")
      activities = activities.limit(per_page).offset((page_num - 1) * per_page) if page_num && per_page
    else
      activities = activities.select("activities.*, op.flagged, op.favicon, op.name").order("op.name ASC")
      activities = IosSdkService.partition_sdks(ios_sdks: activities)
      activities = activities[((page_num - 1) * per_page), per_page] if page_num && per_page
    end
    activities
  end
end
