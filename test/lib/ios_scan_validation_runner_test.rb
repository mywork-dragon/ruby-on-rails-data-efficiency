require 'test_helper'
require 'mocks/redis_mock'

class IosScanValidationRunnerTest < ActiveSupport::TestCase
  def setup
    @job = IpaSnapshotJob.create!
    @app = IosApp.create!(app_identifier: 123)
    @runner = IosScanValidationRunner.new(@job.id, @app.id)
    @redis = RedisMock.new
    @runner.redis = @redis
    @runner.app_info = JSON.parse(open(File.join(Rails.root, 'test', 'data', 'sample_itunes_api.json')).read)['results'].first
    IosDeviceFamily.create!(name: 'iPhone 5s', lookup_name: 'iPhone5s-iPhone5s', active: true)
  end

  test 'handles invalid itunes response' do
    @runner.app_info = IosScanValidationRunner::NoRegisteredStores
    assert_raises IosScanValidationRunner::NoStores do
      @runner.validate_itunes_response!
    end

    @runner.app_info = ItunesApi::EmptyResult
    assert_raises IosScanValidationRunner::NoData do
      @runner.validate_itunes_response!
    end
  end

  test 'handles non-ios apps' do
    @runner.app_info['wrapperType'] = 'mac-software'
    assert_raises IosScanValidationRunner::NotIos do
      @runner.validate_ios!
    end
  end

  test 'handles non-free apps' do
    @runner.app_info['price'] = 99
    assert_raises IosScanValidationRunner::NotFree do
      @runner.validate_price!
    end
  end

  test 'handles incompatible apps' do
    IosDeviceFamily.update_all(active: false)
    assert_raises IosScanValidationRunner::NotDeviceCompatible do
      @runner.validate_device_compatible!
    end
  end

  test 'should update check works' do
    # snapshot does not exist
    assert_equal true, @runner.should_update?

    x = IpaSnapshot.create!
    x.update!(good_as_of_date: 1.week.ago)
    previous_date = x.good_as_of_date
    @app.update!(newest_ipa_snapshot_id: x.id)

    # snapshot does not have version
    assert_equal true, @runner.should_update?
    x.reload
    assert_in_delta previous_date, x.good_as_of_date, 1.second

    # snapshot has non-matching version
    x.update!(version: 'somegarbage')
    assert_equal true, @runner.should_update?
    x.reload
    assert_in_delta previous_date, x.good_as_of_date, 1.second

    # snapshot has identical version
    x.update!(version: @runner.app_info['version'])
    assert_equal false, @runner.should_update?
    x.reload
    assert x.good_as_of_date > previous_date
  end

  test 'recently queued works' do
    # isn't set
    assert_equal false, @runner.recently_queued?

    # is set but to wrong value
    @redis.setex(@runner.recent_key, 1.week, 'old_version')
    assert_equal false, @runner.recently_queued?

    # is set
    @redis.setex(@runner.recent_key, 1.week, @runner.app_info['version'])
    assert_equal true, @runner.recently_queued?
  end

  test 'update job works' do
    @runner.update_job(status: :failed)
    @job.reload
    assert_equal :failed.to_s, @job.live_scan_status
  end
end
