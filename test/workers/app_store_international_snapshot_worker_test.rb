require 'test_helper'
require 'mocks/redis_mock'

class AppStoreInternationalSnapshotWorkerTest < ActiveSupport::TestCase

  def setup
    @snapshot_job = IosAppCurrentSnapshotJob.create!(:notes => 'Testing')
    @itunes_api_response = JSON.parse(File.open(File.join(Rails.root, 'test', 'data', 'sample_itunes_api.json')).read)
    @us_store = AppStore.create(:id => 1, :country_code => 'US', :name => 'United States', :enabled => true, :priority => 1, :display_priority => 1)
    @app1 = IosApp.create(:app_identifier => 418075935) # Bleacher Report
    @app2 = IosApp.create(:app_identifier => 447188370) # Snapchat
  end

  test 'creates snapshot if not found' do
    bulk_store_mock = Minitest::Mock.new

    worker = AppStoreInternationalSnapshotWorker.new
    worker.bulk_store = bulk_store_mock

    app1_response = @itunes_api_response['results'][0]
    app2_response = @itunes_api_response['results'][1]

    ItunesApi.stub :batch_lookup, @itunes_api_response do
      bulk_store_mock.expect :add_data, nil, [@app1, app1_response]
      bulk_store_mock.expect :add_data, nil, [@app2, app2_response]
      bulk_store_mock.expect :save, nil
      bulk_store_mock.expect :snapshots, {}

      worker.perform(@snapshot_job.id, [@app1.id, @app2.id], @us_store.id)
      bulk_store_mock.verify
    end
  end

  test 'doesnt add to bulk store if no difference' do
    app1_snapshot = IosAppCurrentSnapshot.create(:ios_app_id => @app1.id, :app_identifier => 418075935, :app_store_id => @us_store.id, :etag => '5b5a0da2650fae231a0e97025a94a7c3', :latest => true, :name => "SHOULD REMAIN THE SAME")
    app2_snapshot = IosAppCurrentSnapshot.create(:ios_app_id => @app2.id, :app_identifier => 418075935, :app_store_id => @us_store.id, :etag => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', :latest => true, :name => "SHOULD BE OVERRIDDEN")

    worker = AppStoreInternationalSnapshotWorker.new

    app1_response = @itunes_api_response['results'][0]
    app2_response = @itunes_api_response['results'][1]

    ItunesApi.stub :batch_lookup, @itunes_api_response do
      worker.perform(@snapshot_job.id, [@app1.id, @app2.id], @us_store.id)
    end

    app1_snapshots = IosAppCurrentSnapshot.where(:ios_app_id => @app1.id).to_a
    app2_snapshots = IosAppCurrentSnapshot.where(:ios_app_id => @app2.id).to_a
    app2_snapshots_latest = IosAppCurrentSnapshot.where(:ios_app_id => @app2.id).where(:latest => true).to_a

    assert_equal 1, app1_snapshots.length
    assert_equal "SHOULD REMAIN THE SAME", app1_snapshots[0][:name]
    assert_equal 2, app2_snapshots.length
    assert_equal 1, app2_snapshots_latest.length
    assert_equal 'Snapchat', app2_snapshots_latest[0][:name]
  end

  test 'removes app store join if not in response' do
    AppStoresIosApp.create(:app_store_id => @us_store.id, :ios_app_id => @app1.id)
    AppStoresIosApp.create(:app_store_id => @us_store.id, :ios_app_id => @app2.id)

    worker = AppStoreInternationalSnapshotWorker.new

    @itunes_api_response['results'].pop

    app1_response = @itunes_api_response['results'][0]

    ItunesApi.stub :batch_lookup, @itunes_api_response do
      worker.perform(@snapshot_job.id, [@app1.id, @app2.id], @us_store.id)
    end

    assert_not_nil AppStoresIosApp.where(:app_store_id => @us_store.id).where(:ios_app_id => @app1.id).first
    assert_nil AppStoresIosApp.where(:app_store_id => @us_store.id).where(:ios_app_id => @app2.id).first
  end

  test 'removes multiple app store joins not in response' do
    AppStoresIosApp.create(:app_store_id => @us_store.id, :ios_app_id => @app1.id)
    AppStoresIosApp.create(:app_store_id => @us_store.id, :ios_app_id => @app2.id)

    worker = AppStoreInternationalSnapshotWorker.new

    @itunes_api_response['results'].clear

    app1_response = @itunes_api_response['results'][0]

    ItunesApi.stub :batch_lookup, @itunes_api_response do
      worker.perform(@snapshot_job.id, [@app1.id, @app2.id], @us_store.id)
    end

    assert_nil AppStoresIosApp.where(:app_store_id => @us_store.id).where(:ios_app_id => @app1.id).first
    assert_nil AppStoresIosApp.where(:app_store_id => @us_store.id).where(:ios_app_id => @app2.id).first
  end

  test 'sets display type if not ios app' do
    worker = AppStoreInternationalSnapshotWorker.new

    @itunes_api_response['results'][1]['kind'] = "ANDROID APP????"

    app1_response = @itunes_api_response['results'][0]

    ItunesApi.stub :batch_lookup, @itunes_api_response do
      worker.perform(@snapshot_job.id, [@app1.id, @app2.id], @us_store.id)
    end

    assert_equal "not_ios", IosApp.find(@app2.id).display_type
  end

  test 'sets last_scraped if no difference' do
    app1_snapshot = IosAppCurrentSnapshot.create(:ios_app_id => @app1.id, :app_identifier => 418075935, :app_store_id => @us_store.id, :etag => '5b5a0da2650fae231a0e97025a94a7c3', :latest => true, :name => "SHOULD REMAIN THE SAME")
    app2_snapshot = IosAppCurrentSnapshot.create(:ios_app_id => @app2.id, :app_identifier => 418075935, :app_store_id => @us_store.id, :etag => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', :latest => true, :name => "SHOULD BE OVERRIDDEN")

    worker = AppStoreInternationalSnapshotWorker.new

    app1_response = @itunes_api_response['results'][0]
    app2_response = @itunes_api_response['results'][1]

    ItunesApi.stub :batch_lookup, @itunes_api_response do
      worker.perform(@snapshot_job.id, [@app1.id, @app2.id], @us_store.id)
    end

    app1_snapshots = IosAppCurrentSnapshot.where(:ios_app_id => @app1.id).to_a

    assert_equal @snapshot_job.created_at.to_s, app1_snapshots[0].last_scraped.to_s
  end

end