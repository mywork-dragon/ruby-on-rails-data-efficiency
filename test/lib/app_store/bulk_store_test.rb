require 'test_helper'

class BulkStoreTest < ActiveSupport::TestCase

  def setup
    @test_app_json = JSON.parse(File.open(File.join(Rails.root, 'test', 'data', 'test_app.json')).read)
  end

  test 'it correctly sets latest flag' do
    ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create(:notes => 'testing')
    ios_app = IosApp.create(:app_identifier => 1234)
    bulk_store = AppStoreHelper::BulkStore.new(app_store_id: 1, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id, current_tables: true)
    bulk_store.add_data(ios_app, @test_app_json)
    bulk_store.save
    snapshot = IosAppCurrentSnapshot.where('app_identifier = 418075935').first
    assert snapshot.latest
  end

  test 'it correctly sets last_scraped' do
    ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create(:notes => 'testing')
    ios_app = IosApp.create(:app_identifier => 1234)
    bulk_store = AppStoreHelper::BulkStore.new(app_store_id: 1, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id, current_tables: true)
    bulk_store.add_data(ios_app, @test_app_json)
    bulk_store.save
    snapshot = IosAppCurrentSnapshot.where('app_identifier = 418075935').first
    assert_equal ios_app_current_snapshot_job.created_at.to_s, snapshot.last_scraped.to_s
  end

  test 'it correctly sets etag' do
    ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create(:notes => 'testing')
    ios_app = IosApp.create(:app_identifier => 1234)
    bulk_store = AppStoreHelper::BulkStore.new(app_store_id: 1, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id, current_tables: true)
    bulk_store.add_data(ios_app, @test_app_json)
    bulk_store.save
    snapshot = IosAppCurrentSnapshot.where('app_identifier = 418075935').first
    assert_equal '549eafd5b785c539f548fd68e531324a', snapshot.etag
  end

end