# == Schema Information
#
# Table name: ios_app_rankings
#
#  id                          :integer          not null, primary key
#  ios_app_id                  :integer
#  ios_app_ranking_snapshot_id :integer
#  rank                        :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#

class IosAppRanking < ActiveRecord::Base
  has_many :weekly_batches, as: :owner

  belongs_to :ios_app
  belongs_to :ios_app_ranking_snapshot

  after_commit :log_activity, on: :create

  def log_activity
    snapshot_date = self.ios_app_ranking_snapshot.created_at
    was_top_200 = self.ios_app.ios_app_rankings.where(created_at: snapshot_date-1.week..snapshot_date).where.not(id: self.id).any?
    Activity.log_activity(:entered_top_apps, self.ios_app_ranking_snapshot.created_at, ios_app, self) unless was_top_200
  end
end
