class AddIndexToApplicationIdAndEpfFullFeedId < ActiveRecord::Migration
  def change
    add_index :ios_app_epf_snapshots, [:application_id, :epf_full_feed_id], name: :index_application_id_and_epf_full_feed_id
  end
end
