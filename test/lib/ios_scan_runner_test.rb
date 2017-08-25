require 'test_helper'
require 'mocks/redshift_logger_mock'

class IosScanRunnerTest < ActiveSupport::TestCase
  def setup
    lookup_data = JSON.load(open(File.join(Rails.root, 'test', 'data', 'uber_itunes_lookup.json')))['results'][0]
    @app_store = AppStore.create!(country_code: 'blah')
    @app = IosApp.create!(app_identifier: 368677368)
    @snapshot = IpaSnapshot.create!(
      ios_app_id: @app.id,
      version: lookup_data['version'],
      lookup_content: JSON.dump(lookup_data),
      app_store: @app_store)
    @app.update!(newest_ipa_snapshot: @snapshot)
  end

  def test_already_scanned
    snapshot = @snapshot.dup
    snapshot.save!
    runner = IosScanRunner.new(snapshot.id, :mass, {check_repeated_scan: true})
    runner.rs_logger = RedshiftLoggerMock.new

    runner.run
    snapshot.reload
    assert_equal true, snapshot.success
    assert_equal 'unchanged', snapshot.download_status
    sent_records = runner.rs_logger.sent_records
    assert_equal 1, sent_records.count
    assert_equal 'ios_scan_unchanged', sent_records.first[:name]
  end

  def test_log_rs_metric
    runner = IosScanRunner.new(@snapshot.id, :mass)
    runner.rs_logger = RedshiftLoggerMock.new
    runner.load_job_info
    runner.log_rs_metric('dummy')

    sent_records = runner.rs_logger.sent_records
    assert_equal 1, sent_records.count
    assert_equal 'dummy', sent_records.first[:name]
  end
end
