require 'test_helper'
require 'mocks/mighty_aws_s3_mock'

class GooglePlayChartWorkerTest < ActiveSupport::TestCase

  def setup
    @s3 = MightyAwsS3Mock.new
    @worker = GooglePlayChartWorker.new
    @worker.s3_client = @s3
  end

  test 'fails to validate when too few entries' do
    example_data = {
      'rankings' => {
        'com.ubercab' => { 'rank' => 1 }
      }
    }
    assert_raises(GooglePlayChartWorker::InvalidRankings) { @worker.validate!(example_data) }
  end

  test 'validates good entry' do
    example_data = JSON.parse(File.open(File.join(Rails.root, 'test', 'data', 'gplay_top_200_scrape.json')).read)

    assert_nil @worker.validate!(example_data)
  end

  test 'properly extracts new apps' do
    app = AndroidApp.create!(app_identifier: 'test')
    example_data = {
      'rankings' => {
        'com.ubercab' => { 'rank' => 1 },
        'test' => { 'rank' => 2 }
      }
    }

    new_app_ids = @worker.extract_new_apps(example_data)
    assert_equal 1, new_app_ids.count
    assert_not_equal app.id, new_app_ids.first
  end

  test 'stores rankings for apps' do
    app = AndroidApp.create!(app_identifier: 'test')
    example_data = {
      'rankings' => {
        'test' => { 'rank' => 10 }
      }
    }
    @worker.store_rankings(example_data)
    assert AndroidAppRankingSnapshot.last
    assert AndroidAppRankingSnapshot.last.is_valid

    rankings = AndroidAppRankingSnapshot.last.android_app_rankings
    assert_equal 1, rankings.count
    assert_equal 10, rankings.take.rank
    assert_equal app.id, rankings.take.android_app_id
  end

  test 'stores processed' do
    example_data = {
      'rankings' => {
        'test' => { 'rank' => 10 }
      }
    }
    @worker.store_processed(example_data)
    assert_equal "top_free/processed/#{Digest::SHA1.hexdigest(example_data.to_json)}", @s3.key_stored_to
    assert_equal '', @s3.data
  end
end
