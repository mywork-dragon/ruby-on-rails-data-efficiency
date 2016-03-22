class Activity < ActiveRecord::Base
  has_many :weekly_batches_activities
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

    activity = Activity.create(happened_at: time)
    owners.each do |owner|
      # create a weekly batch for each owner and add activity to it
      current_weekly_batch = owner.weekly_batches.find_or_create_by(week: current_week, activity_type: WeeklyBatch.activity_types[activity_type])
      current_weekly_batch.activities << activity
    end
  end

  def other_owner(owner)
    if @other_owner.blank?
      owners = self.weekly_batches.map{|batch| batch.owner}
      owners.delete(owner)
      @other_owner = owners.first
    else
      @other_owner
    end
  end
end
