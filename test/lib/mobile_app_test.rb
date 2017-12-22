require 'test_helper'

class MobileAppTest < ActiveSupport::TestCase
  def setup
    # iOS setup
    @ios_app = IosApp.create!(app_identifier: 123123)
    @ipa_snapshot = IpaSnapshot.create!(
      ios_app: @ios_app,
      scan_status: IpaSnapshot.scan_statuses[:scanned])
    @ios_app.update!(newest_ipa_snapshot: @ipa_snapshot)
    @ios_sdks = ['a', 'b', 'c'].map do |name|
      IosSdk.create(name: name, uid: name, kind: :native, website: 'google.com')
    end
    @ios_sdks.each do |sdk|
      IosSdksIpaSnapshot.create!(ipa_snapshot: @ipa_snapshot, ios_sdk: sdk)
    end

    # Android setup
    @android_app = AndroidApp.create!(app_identifier: 'asdf')
    @apk_snapshot = ApkSnapshot.create!(
      android_app: @android_app,
      scan_status: ApkSnapshot.scan_statuses[:scan_success])
    @android_app.update!(newest_apk_snapshot: @apk_snapshot)
    @android_sdks = ['a', 'b', 'c'].map do |name|
      AndroidSdk.create!(name: name, favicon: 'www.google.com', website: 'google.com', kind: :native)
    end
    @android_sdks.each do |sdk|
      AndroidSdksApkSnapshot.create!(apk_snapshot: @apk_snapshot, android_sdk: sdk)
    end

    @tag = Tag.create!(name: 'Attribution')
  end

  def create_snapshot(date)
    s = IpaSnapshot.create!(
      ios_app: @ios_app,
      scan_status: IpaSnapshot.scan_statuses[:scanned])
    s.update!(good_as_of_date: date, first_valid_date: date)
    s
  end

  test 'sdk history function returns valid response' do
    res = @ios_app.sdk_history
    assert_equal @ios_sdks.count, res[:installed_sdks].count
    assert_equal 0, res[:uninstalled_sdks].count
    @ios_sdks.each do |sdk|
      sdk_section = res[:installed_sdks].select {|x| x['id'] == sdk.id }
      assert_equal 1, sdk_section.count
      sdk_section = sdk_section.first
      assert_equal @ipa_snapshot.first_valid_date.to_i, sdk_section['first_seen_date'].to_i
      assert_equal @ipa_snapshot.good_as_of_date.to_i, sdk_section['last_seen_date'].to_i
      activities = sdk_section['activities']
      assert_equal 1, activities.count
      assert_equal :install, activities.first['type']
      assert_equal @ipa_snapshot.first_valid_date.to_i, activities.first['date'].to_i
    end

    assert_equal @ipa_snapshot.good_as_of_date.to_i, res[:updated].to_i
  end

  test 'flagged sdks are ignored' do
    flagged = @ios_sdks.first
    flagged.update!(flagged: true)
    res = @ios_app.sdk_history
    assert_equal 2, res[:installed_sdks].count
  end

  test 'duplicate sdk attributions do not result in multiple install events' do
    oldest_snapshot = create_snapshot(1.month.ago)
    old_snapshot = create_snapshot(1.week.ago)

    sdk = @ios_sdks.first
    IosSdksIpaSnapshot.create!(ipa_snapshot: oldest_snapshot, ios_sdk: sdk)
    IosSdksIpaSnapshot.create!(ipa_snapshot: @ipa_snapshot, ios_sdk: sdk, method: :frameworks) # create duplicate attribution
    res = @ios_app.sdk_history
    sdk_section = res[:installed_sdks].select { |x| x['id'] == sdk.id }.first
    assert sdk_section
    assert_equal 2, sdk_section['activities'].select { |x| x['type'] == :install }.count
  end

  test 'duplicate sdk attributions do not result in multiple uninstall events' do
    old_snapshot = create_snapshot(1.week.ago)
    uninstalled_sdk = @ios_sdks.first
    @ios_sdks.each do |sdk|
      IosSdksIpaSnapshot.create!(ipa_snapshot: old_snapshot, ios_sdk: sdk)
    end
    # create duplicate attribution
    IosSdksIpaSnapshot.create!(ipa_snapshot: old_snapshot, ios_sdk: uninstalled_sdk, method: :frameworks)
    @ipa_snapshot.ios_sdks_ipa_snapshots.where('ios_sdk_id = ?', uninstalled_sdk.id).delete_all
    res = @ios_app.sdk_history
    sdk_section = res[:uninstalled_sdks].select { |x| x['id'] == uninstalled_sdk.id }.first
    assert_equal 1, sdk_section['activities'].select { |x| x['type'] == :uninstall }.count # one install, one uninstall
  end

  test 'sdk history function returns valid response for android as well' do
    res = @android_app.sdk_history
    assert_equal @android_sdks.count, res[:installed_sdks].count
    assert_equal 0, res[:uninstalled_sdks].count
    @android_sdks.each do |sdk|
      sdk_section = res[:installed_sdks].select {|x| x['id'] == sdk.id }
      assert_equal 1, sdk_section.count
      sdk_section = sdk_section.first
      assert_equal @apk_snapshot.first_valid_date.to_i, sdk_section['first_seen_date'].to_i
      assert_equal @apk_snapshot.good_as_of_date.to_i, sdk_section['last_seen_date'].to_i
      activities = sdk_section['activities']
      assert_equal 1, activities.count
      assert_equal :install, activities.first['type']
      assert_equal @apk_snapshot.first_valid_date.to_i, activities.first['date'].to_i
    end
  end

   test 'tagged sdks returns valid response for iOS' do
     @ios_sdks.first.tags << @tag
     res = @ios_app.tagged_sdk_history
     assert_equal 2, res[:installed_sdks].count
     assert_equal 0, res[:uninstalled_sdks].count
     assert_equal 2, res[:installed_sdks].select { |x| x[:name] == 'Others' }.first[:sdks].count
     assert_equal 1, res[:installed_sdks].select { |x| x[:name] == @tag.name }.first[:sdks].count
     assert_equal 3, res[:installed_sdks_count]
     assert_equal 0, res[:uninstalled_sdks_count]

     res = @ios_app.tagged_sdk_history(true)
     assert_equal 1, res[:installed_sdks].count
     assert_equal 0, res[:installed_sdks].select { |x| x[:name] == 'Others' }.count
   end 

   test 'tagged sdks returns valid response for Android' do
     @android_sdks.first.tags << @tag
     res = @android_app.tagged_sdk_history
     assert_equal 2, res[:installed_sdks].count
     assert_equal 0, res[:uninstalled_sdks].count
     assert_equal 2, res[:installed_sdks].select { |x| x[:name] == 'Others' }.first[:sdks].count
     assert_equal 1, res[:installed_sdks].select { |x| x[:name] == @tag.name }.first[:sdks].count
     assert_equal 3, res[:installed_sdks_count]
     assert_equal 0, res[:uninstalled_sdks_count]

     res = @android_app.tagged_sdk_history(true)
     assert_equal 1, res[:installed_sdks].count
     assert_equal 0, res[:installed_sdks].select { |x| x[:name] == 'Others' }.count
   end 

   test 'tagged sdks returns sdk arrays in sorted order by tag name' do
     @ios_sdks.last.tags << @tag # Attribution should come before Others
     res = @ios_app.tagged_sdk_history

     [:installed_sdks, :uninstalled_sdks].each do |k|
       previous = res[k].first.try(:[], :name) || 'empty'
       res[k].each do |x|
         assert x[:name] >= previous
         previous = x[:name]
       end
     end
   end
end
