require 'test_helper'

class IosClassificationRunnerTest < ActiveSupport::TestCase

  def setup
    @mock = MiniTest::Mock.new
    @app = IosApp.create!(app_identifier: 1234123)
    @snapshot = IpaSnapshot.create!(ios_app: @app)
  end

  test 'updates scan status' do
    assert_nil @snapshot.scan_status

    runner = IosClassificationRunner.new(@snapshot.id)
    runner.stub :classify, nil do
      runner.run
    end

    assert_equal 'scanned', @snapshot.reload.scan_status
  end

  test 'does not update scan status when specified' do
    assert_nil @snapshot.scan_status
    runner = IosClassificationRunner.new(
      @snapshot.id,
      {
        disable_status_updates: true
      }
    )
    runner.stub :classify, nil do
      runner.run
    end
    assert_nil @snapshot.scan_status
  end

  test 'does not call activity logging' do
    runner = IosClassificationRunner.new(
      @snapshot.id,
      {
        disable_activity_logging: true
      }
    )

    raises = -> { raise RuntimeError }

    runner.stub :classify, nil do
      runner.stub :log_activities, raises do
        runner.run
      end
    end
  end

  test 'passes classification options through to classifier' do
    classification_options = {hi: 1}
    runner = IosClassificationRunner.new(
      @snapshot_id,
      {
        classification_options: classification_options
      }
    )
    assert_equal classification_options, runner.classifier.options
  end
end
