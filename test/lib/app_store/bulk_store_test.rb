require 'test_helper'

class BulkStoreTest < ActiveSupport::TestCase

  def setup
    @test_app_json = JSON.parse(File.open(File.join(Rails.root, 'test', 'data', 'test_app.json')).read)
  end

  test 'it correctly sets snapshot attributes' do
    ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create(:notes => 'testing')
    ios_app = IosApp.create(:app_identifier => 1234)
    us_store = AppStore.create(:id => 1, :country_code => 'US', :name => 'United States', :enabled => true, :priority => 1, :display_priority => 1)
    bulk_store = AppStoreHelper::BulkStore.new(app_store_id: us_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    bulk_store.add_data(ios_app, @test_app_json)
    bulk_store.save
    
    snapshot = IosAppCurrentSnapshot.where('app_identifier = 418075935').first

    # MightySignal table attributes
    assert_equal ios_app.id, snapshot.ios_app_id
    assert_equal ios_app_current_snapshot_job.id, snapshot.ios_app_current_snapshot_job_id
    assert_equal us_store.id, snapshot.app_store_id
    assert snapshot.latest
    assert_equal ios_app_current_snapshot_job.created_at.to_s, snapshot.last_scraped.to_s
    assert_equal '549eafd5b785c539f548fd68e531324a', snapshot.etag

    # Itunes API attributes
    assert_equal 'Bleacher Report: Sports news, scores, & highlights', snapshot.name
    assert_equal 0, snapshot.price
    assert_equal '5.2', snapshot.version
    assert_equal '12+', snapshot.recommended_age
    assert_equal 'Your Team\'s News First!', snapshot.description
    assert_equal 'com.bleacherreport.TeamStream', snapshot.bundle_identifier
    assert_equal 'USD', snapshot.currency
  end

  test 'it correctly sets ratings_per_day' do
    five_days_ago = JSON.parse(File.open(File.join(Rails.root, 'test', 'data', 'test_app.json')).read)
    five_days_ago['currentVersionReleaseDate'] = 5.days.ago.utc.iso8601

    ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create(:notes => 'testing')
    ios_app = IosApp.create(:app_identifier => 1234)
    us_store = AppStore.create(:id => 1, :country_code => 'US', :name => 'United States', :enabled => true, :priority => 1, :display_priority => 1)
    bulk_store = AppStoreHelper::BulkStore.new(app_store_id: us_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    bulk_store.add_data(ios_app, five_days_ago)
    bulk_store.save
    
    snapshot = IosAppCurrentSnapshot.where('app_identifier = 418075935').first

    # BulkStore sometimes adds a day when calculating the average ratings per day.
    assert (snapshot.ratings_per_day_current_release - (53/5.0)).abs < 0.1 || (snapshot.ratings_per_day_current_release - (53/6.0)).abs < 0.1
  end

  test 'it correctly sets mobile_priority high' do
    high_mobile_priority_json = JSON.parse(File.open(File.join(Rails.root, 'test', 'data', 'test_app.json')).read)
    high_mobile_priority_json['currentVersionReleaseDate'] = 5.days.ago.utc.iso8601

    ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create(:notes => 'testing')
    ios_app = IosApp.create(:app_identifier => 1234)
    us_store = AppStore.create(:id => 1, :country_code => 'US', :name => 'United States', :enabled => true, :priority => 1, :display_priority => 1)
    bulk_store = AppStoreHelper::BulkStore.new(app_store_id: us_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    bulk_store.add_data(ios_app, high_mobile_priority_json)
    bulk_store.save
    
    snapshot = IosAppCurrentSnapshot.where('app_identifier = 418075935').first

    assert_equal 'high', snapshot.mobile_priority
  end

  test 'it correctly sets mobile_priority medium' do
    high_mobile_priority_json = JSON.parse(File.open(File.join(Rails.root, 'test', 'data', 'test_app.json')).read)
    high_mobile_priority_json['currentVersionReleaseDate'] = 3.months.ago.utc.iso8601

    ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create(:notes => 'testing')
    ios_app = IosApp.create(:app_identifier => 1234)
    us_store = AppStore.create(:id => 1, :country_code => 'US', :name => 'United States', :enabled => true, :priority => 1, :display_priority => 1)
    bulk_store = AppStoreHelper::BulkStore.new(app_store_id: us_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    bulk_store.add_data(ios_app, high_mobile_priority_json)
    bulk_store.save
    
    snapshot = IosAppCurrentSnapshot.where('app_identifier = 418075935').first

    assert_equal 'medium', snapshot.mobile_priority
  end

  test 'it correctly sets mobile_priority low' do
    high_mobile_priority_json = JSON.parse(File.open(File.join(Rails.root, 'test', 'data', 'test_app.json')).read)
    high_mobile_priority_json['currentVersionReleaseDate'] = 10.months.ago.utc.iso8601

    ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create(:notes => 'testing')
    ios_app = IosApp.create(:app_identifier => 1234)
    us_store = AppStore.create(:id => 1, :country_code => 'US', :name => 'United States', :enabled => true, :priority => 1, :display_priority => 1)
    bulk_store = AppStoreHelper::BulkStore.new(app_store_id: us_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    bulk_store.add_data(ios_app, high_mobile_priority_json)
    bulk_store.save
    
    snapshot = IosAppCurrentSnapshot.where('app_identifier = 418075935').first

    assert_equal 'low', snapshot.mobile_priority
  end

  test 'it correctly sets user_base' do
    il_test_app_json = @test_app_json.clone
    il_test_app_json['userRatingCount'] = 13
    il_test_app_json['userRatingCountForCurrentVersion'] = 1

    jp_test_app_json = @test_app_json.clone
    jp_test_app_json['userRatingCount'] = 11
    jp_test_app_json['userRatingCountForCurrentVersion'] = 0

    ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create(:notes => 'testing')
    ios_app = IosApp.create(:app_identifier => 1234)
    us_store = AppStore.create(:id => 1, :country_code => 'US', :name => 'United States', :enabled => true, :priority => 1, :display_priority => 1)
    il_store = AppStore.create(:id => 4, :country_code => 'IL', :name => 'Israel', :enabled => true, :priority => 3, :display_priority => 5)
    jp_store = AppStore.create(:id => 2, :country_code => 'JP', :name => 'Japan',  :enabled => true, :priority => 2, :display_priority => 4)
    us_bulk_store = AppStoreHelper::BulkStore.new(app_store_id: us_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    il_bulk_store = AppStoreHelper::BulkStore.new(app_store_id: il_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    jp_bulk_store = AppStoreHelper::BulkStore.new(app_store_id: jp_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    us_bulk_store.add_data(ios_app, @test_app_json)
    il_bulk_store.add_data(ios_app, il_test_app_json)
    jp_bulk_store.add_data(ios_app, jp_test_app_json)
    us_bulk_store.save
    il_bulk_store.save
    jp_bulk_store.save
    
    us_snapshot = IosAppCurrentSnapshot.where('app_identifier = 418075935').where('app_store_id = 1').first
    il_snapshot = IosAppCurrentSnapshot.where('app_identifier = 418075935').where('app_store_id = 4').first
    jp_snapshot = IosAppCurrentSnapshot.where('app_identifier = 418075935').where('app_store_id = 2').first

    # Ratings per day can sometimes skew the ratings down a tier, so check the expected
    # tier and the tier below for non-weak user bases.
    assert us_snapshot.user_base == 'strong' || us_snapshot.user_base == 'moderate'
    assert il_snapshot.user_base == 'elite' || il_snapshot.user_base == 'strong'
    assert_equal 'weak', jp_snapshot.user_base
  end

  test 'it correctly creates and associates existing categories' do
    ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create(:notes => 'testing')
    ios_app = IosApp.create(:app_identifier => 1234)
    us_store = AppStore.create(:id => 1, :country_code => 'US', :name => 'United States', :enabled => true, :priority => 1, :display_priority => 1)
    sports_category = IosAppCategory.create(:name => 'Sports', :category_identifier => '6004')
    news_category = IosAppCategory.create(:name => 'News', :category_identifier => '6009')
    bulk_store = AppStoreHelper::BulkStore.new(app_store_id: us_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    bulk_store.add_data(ios_app, @test_app_json)
    bulk_store.save

    snapshot = IosAppCurrentSnapshot.where('app_identifier = 418075935').first
    primary_category_join = IosAppCategoriesCurrentSnapshot
      .where(:ios_app_category_id => sports_category.id)
      .where(:ios_app_current_snapshot_id => snapshot.id)
      .where(:kind => 0).first
    secondary_category_join = IosAppCategoriesCurrentSnapshot
      .where(:ios_app_category_id => news_category.id)
      .where(:ios_app_current_snapshot_id => snapshot.id)
      .where(:kind => 1).first

    assert snapshot
    assert primary_category_join
    assert secondary_category_join
  end

  test 'it correctly creates and associates missing categories' do
    ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create(:notes => 'testing')
    ios_app = IosApp.create(:app_identifier => 1234)
    us_store = AppStore.create(:id => 1, :country_code => 'US', :name => 'United States', :enabled => true, :priority => 1, :display_priority => 1)
    bulk_store = AppStoreHelper::BulkStore.new(app_store_id: us_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    bulk_store.add_data(ios_app, @test_app_json)
    bulk_store.save

    snapshot = IosAppCurrentSnapshot.where('app_identifier = 418075935').first
    sports_category = IosAppCategory.where(:name => 'Sports').first
    news_category = IosAppCategory.where(:name => 'News').first
    primary_category_join = IosAppCategoriesCurrentSnapshot
      .where(:ios_app_category_id => sports_category.id)
      .where(:ios_app_current_snapshot_id => snapshot.id)
      .where(:kind => 0).first
    secondary_category_join = IosAppCategoriesCurrentSnapshot
      .where(:ios_app_category_id => news_category.id)
      .where(:ios_app_current_snapshot_id => snapshot.id)
      .where(:kind => 1).first

    assert snapshot
    assert sports_category
    assert news_category
    assert primary_category_join
    assert secondary_category_join
  end

  test 'it correctly joins snapshots to stores' do
    ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create(:notes => 'testing')
    ios_app = IosApp.create(:app_identifier => 1234)
    us_store = AppStore.create(:id => 1, :country_code => 'US', :name => 'United States', :enabled => true, :priority => 1, :display_priority => 1)
    il_store = AppStore.create(:id => 4, :country_code => 'IL', :name => 'Israel', :enabled => true, :priority => 3, :display_priority => 5)
    jp_store = AppStore.create(:id => 2, :country_code => 'JP', :name => 'Japan',  :enabled => true, :priority => 2, :display_priority => 4)
    us_bulk_store = AppStoreHelper::BulkStore.new(app_store_id: us_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    il_bulk_store = AppStoreHelper::BulkStore.new(app_store_id: il_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    jp_bulk_store = AppStoreHelper::BulkStore.new(app_store_id: jp_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    us_bulk_store.add_data(ios_app, @test_app_json)
    il_bulk_store.add_data(ios_app, @test_app_json)
    jp_bulk_store.add_data(ios_app, @test_app_json)
    us_bulk_store.save
    il_bulk_store.save
    jp_bulk_store.save

    assert AppStoresIosApp.where(:ios_app_id => ios_app.id).where(:app_store_id => 1).first
    assert AppStoresIosApp.where(:ios_app_id => ios_app.id).where(:app_store_id => 4).first
    assert AppStoresIosApp.where(:ios_app_id => ios_app.id).where(:app_store_id => 2).first
  end

  test 'it correctly unsets latest from previous snapshots' do
    ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.create(:notes => 'testing')
    ios_app = IosApp.create(:app_identifier => 1234)
    us_store = AppStore.create(:id => 1, :country_code => 'US', :name => 'United States', :enabled => true, :priority => 1, :display_priority => 1)
    first_snapshot = IosAppCurrentSnapshot.create(:ios_app_id => ios_app.id, :app_store_id => 1, latest: true, :name => 'FIRST SNAPSHOT')
    first_snapshot_in_wrong_store = IosAppCurrentSnapshot.create(:ios_app_id => ios_app.id, :app_store_id => 2, latest: true, :name => 'FIRST SNAPSHOT')
    us_bulk_store = AppStoreHelper::BulkStore.new(app_store_id: us_store.id, ios_app_current_snapshot_job_id: ios_app_current_snapshot_job.id)
    us_bulk_store.add_data(ios_app, @test_app_json)
    us_bulk_store.save

    snapshot = IosAppCurrentSnapshot.where(:ios_app_id => ios_app.id).where(:app_store_id => 1).where(:latest => true).first

    assert_not IosAppCurrentSnapshot.find(first_snapshot.id).latest
    assert IosAppCurrentSnapshot.find(first_snapshot_in_wrong_store.id).latest
    assert snapshot
    assert_equal 'Bleacher Report: Sports news, scores, & highlights', snapshot.name
  end

end