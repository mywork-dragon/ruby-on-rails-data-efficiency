class WeeklyBatch < ActiveRecord::Base
  validates :activity_type, presence: true
  
  has_many :weekly_batches_activities
  has_many :activities, through: :weekly_batches_activities

  belongs_to :owner, polymorphic: true

  enum activity_type: [:install, :uninstall]

  def sorted_activities(page_num, per_page)
    if self.owner_type == 'IosSdk' || self.owner_type == 'AndroidSdk'
      opposite_type = self.owner.platform.titleize + 'App'
    else
      opposite_type = self.owner.platform.titleize + 'Sdk'
    end
    opposite_class = opposite_type.constantize

    activities =  self.activities.joins('INNER JOIN weekly_batches_activities wb on wb.activity_id = activities.id').
                                    joins('INNER JOIN weekly_batches on weekly_batches.id = wb.weekly_batch_id').
                                    joins("INNER JOIN #{opposite_class.table_name} op on op.id = weekly_batches.owner_id and weekly_batches.owner_type = '#{opposite_type}'")
    if self.owner_type == 'IosSdk' || self.owner_type == 'AndroidSdk'
      activities = activities.order("op.user_base ASC").limit(per_page).offset((page_num - 1) * per_page)
    else
      activities = activities.select("activities.*, op.flagged, op.favicon, op.name")
      activities = activities.order("op.name ASC")
      activities = IosSdkService.partition_sdks(ios_sdks: activities)[((page_num - 1) * per_page), per_page]
    end
  end
end
