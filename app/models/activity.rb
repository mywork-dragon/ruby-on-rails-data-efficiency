class Activity < ActiveRecord::Base
  has_many :weekly_batches_activities, dependent: :destroy
  has_many :weekly_batches, through: :weekly_batches_activities

  def self.log_activity(activity_type, time, *owners)
    # create activity, could pass in data in the future
    return if activity_type.blank? || owners.empty?

    if Rails.env.development?
      current_week = Date.today.at_beginning_of_week + [-1, -2, -3, 0].sample.weeks
    else
      current_week = time.to_date.at_beginning_of_week
    end

    # make sure we don't record same activity
    if owners.count > 1
      first_owner = owners.first
      second_owner = owners.last
      if weekly_batch = first_owner.weekly_batches.where(activity_type: WeeklyBatch.activity_types[activity_type], week: current_week).first
        return if weekly_batch.activities.joins(:weekly_batches).where("owner_type = ? and owner_id = ?", second_owner.class.name, second_owner.id).any?
      end
    end

    is_major_app = owners.any? { |owner| (owner.class.name == "IosApp" || owner.class.name == "AndroidApp") && (owner.is_major_app? || owner.major_app_tag?) }

    activity = Activity.create(happened_at: time, major_app: is_major_app)
    owners.each do |owner|
      # create a weekly batch for each owner and add activity to it
      current_weekly_batch = owner.weekly_batches.find_or_create_by(week: current_week, activity_type: WeeklyBatch.activity_types[activity_type])
      current_weekly_batch.activities << activity
      current_weekly_batch.clear_cache
    end
    activity.notify
  end

  def self.remove_activity(activity_type, time, *owners)
    return if activity_type.blank? || owners.empty?
    week = time.to_date.at_beginning_of_week
    weekly_batch = owners.first.weekly_batches.where(week: week, activity_type: WeeklyBatch.activity_types[activity_type]).first

    return unless weekly_batch

    if owners.count > 1
      first_owner = owners.first
      second_owner = owners.last
      activity = weekly_batch.activities.joins(:weekly_batches).where("owner_type = ? and owner_id = ?", second_owner.class.name, second_owner.id).first
    else
      activity = weekly_batch.activities.first
    end

    return unless activity

    weekly_batches = activity.weekly_batches.to_a
    activity.destroy
    weekly_batches.each do |batch|
      if batch.reload.activities.empty?
        batch.destroy
      else
        WeeklyBatch.reset_counters(batch.id, :activities)
        batch.clear_cache
      end
    end
  end

  def notify
    should_notify = false
    self.weekly_batches.each do |batch|
      if batch.owner.try(:is_in_top_200?) && ['install', 'entered_top_apps'].include?(batch.activity_type) && (happened_at > Time.now - 2.days)
        should_notify = true
        break
      end
    end
    TwitterPostWorker.perform_async(:post_activity, self.id) if should_notify
  end

  def activity_type
    self.weekly_batches.first.try(:activity_type)
  end

  def owners
    self.weekly_batches.map{|batch| batch.owner}
  end

  def other_owner(owner)
    if @other_owner.blank?
      all_owners = owners
      all_owners.delete(owner)
      @other_owner = all_owners.first
    else
      @other_owner
    end
  end

  def invalidate!
    batches = self.weekly_batches
    self.destroy
    batches.each do |batch|
      WeeklyBatch.reset_counters(batch.id, :activities)
    end

    batches.each do |b|
      b.reload
      b.destroy if b.activities_count == 0
    end
  end
end
