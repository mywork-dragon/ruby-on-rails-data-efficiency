require "rails_helper"
require '/varys/lib/tasks/one_off/fix_categories_task'

describe FixCategoriesTask do
  let(:kinds) { {primary: 0, secondary: 1} }
  let(:stream_name) { 'category_fix' }


  describe '.android_perform' do
    let(:android_category_data) { {category_id: 'CAT1', category_name: 'Cat1'} }

    before :each do
      @android_app = FactoryGirl.create(:android_app)
      allow(GooglePlayService).to receive(:attributes).and_return(android_category_data)
      allow(MightyAws::Firehose).to receive(:send).and_return(true)
    end 

    it 'fix android app categories' do
      subject.android_perform(@android_app)

      expect(@android_app.categories).to eq([android_category_data[:category_name]])
    end

    it 'android app no newest snaphot' do
      firehose = instance_double("MightyAws::Firehose")
      expect(firehose).to receive(:send).with(stream_name: stream_name, data: "android, #{@android_app.id}, App has never been scanned")

      @android_app.newest_android_app_snapshot = nil
      @android_app.save!

      subject.firehose = firehose
      subject.android_perform(@android_app)

      # If the app has no ios_app_current_snapshots means it has never been scanned
      # then we can't update the categories nor create new ones
      expect(@android_app.categories).to eq([])
    end

    it 'android category exists with same name and different id ' do
      cat1 = FactoryGirl.create(:android_app_category, name: 'Test', category_id: 'CAT1')
      @android_app.newest_android_app_snapshot.android_app_categories = [cat1]
      @android_app.save!

      subject.android_perform(@android_app)
      the_category = AndroidAppCategory.find_by(category_id: android_category_data[:category_id])

      expect(@android_app.categories).to eq([cat1.name])
      expect(the_category.name).to eq(cat1.name)
    end
  end

  describe '.ios_perform' do
    let(:ios_category_data) { {categories: {primary: 'Cat1', secondary:['Cat2']}} }

    before :each do
      @ios_app = FactoryGirl.create(:ios_app)
      allow(AppStoreService).to receive(:attributes).and_return(ios_category_data)
      allow(MightyAws::Firehose).to receive(:send).and_return(true)
    end

    it 'update ios app primary  category' do
      test_category_data = {categories: {primary: 'Cat1', secondary:[]}}
      allow(AppStoreService).to receive(:attributes).and_return(test_category_data)

      subject.ios_perform(@ios_app)

      snapshot = @ios_app.ios_app_current_snapshots.where(latest: true).first
      primary_category, secondary_category = get_ios_expected_categories(@ios_app)
      
      expect(@ios_app.categories).to eq([test_category_data[:categories][:primary]])
      expect(primary_category.name).to eq(test_category_data[:categories][:primary])
      expect(secondary_category).to eq(nil)
    end

    it 'update ios app primary and secondary category' do
      subject.ios_perform(@ios_app)

      snapshot = @ios_app.ios_app_current_snapshots.where(latest: true).first

      primary_category, secondary_category = get_ios_expected_categories(@ios_app)

      expect(@ios_app.categories).to eq([ios_category_data[:categories][:primary]])
      expect(primary_category.name).to eq(ios_category_data[:categories][:primary])
      expect(secondary_category.name).to eq(ios_category_data[:categories][:secondary].first)
    end

    it 'process ios app no current snaphots' do
      firehose = instance_double("MightyAws::Firehose")
      expect(firehose).to receive(:send).with(stream_name: stream_name, data: "ios, #{@ios_app.id}, App has never been scanned")

      @ios_app.ios_app_current_snapshots = []
      @ios_app.save!

      subject.firehose = firehose
      subject.ios_perform(@ios_app)
      
      # If the app has no ios_app_current_snapshots means it has never been scanned
      # then we can't update the categories nor create new ones
      expect(@ios_app.categories).to eq([])
    end

    it 'current snapshot with no primary category' do
      snapshot = @ios_app.ios_app_current_snapshots.where(latest: true).first
      IosAppCategoriesCurrentSnapshot
        .where(ios_app_current_snapshot_id: snapshot.id)
        .where(kind: kinds[:primary]).destroy_all

      subject.ios_perform(@ios_app)

      primary_category, secondary_category = get_ios_expected_categories(@ios_app)
      expect(@ios_app.categories).to eq([ios_category_data[:categories][:primary]])
      expect(primary_category.name).to eq(ios_category_data[:categories][:primary])
      expect(secondary_category.name).to eq(ios_category_data[:categories][:secondary].first)
    end

    it 'current snapshot with no secondary category' do
      remove_ios_category(@ios_app, kinds[:primary])

      subject.ios_perform(@ios_app)

      primary_category, secondary_category = get_ios_expected_categories(@ios_app)
      expect(@ios_app.categories).to eq([ios_category_data[:categories][:primary]])
      expect(primary_category.name).to eq(ios_category_data[:categories][:primary])
      expect(secondary_category.name).to eq(ios_category_data[:categories][:secondary].first)
    end

    it 'current snapshot with no primary and secondary categories' do
      remove_ios_category(@ios_app, kinds[:primary])
      remove_ios_category(@ios_app, kinds[:secondary])

      subject.ios_perform(@ios_app)

      primary_category, secondary_category = get_ios_expected_categories(@ios_app)
      expect(@ios_app.categories).to eq([ios_category_data[:categories][:primary]])
      expect(primary_category.name).to eq(ios_category_data[:categories][:primary])
      expect(secondary_category.name).to eq(ios_category_data[:categories][:secondary].first)
    end

    it 'clean corrupted categories' do
      @ios_app.ios_app_current_snapshots << FactoryGirl.create_list(:ios_app_current_snapshot, 3, latest: true)

      expect(@ios_app.ios_app_current_snapshots.where(latest: true).count).to eq(4)

      subject.ios_perform(@ios_app)

      expect(@ios_app.ios_app_current_snapshots.where(latest: true).count).to eq(1)

      primary_category, secondary_category = get_ios_expected_categories(@ios_app)
      expect(@ios_app.categories).to eq([ios_category_data[:categories][:primary]])
      expect(primary_category.name).to eq(ios_category_data[:categories][:primary])
      expect(secondary_category.name).to eq(ios_category_data[:categories][:secondary].first)
    end
  end
end

def remove_ios_category(ios_app, kind)
    snapshot = ios_app.ios_app_current_snapshots.where(latest: true).first
    IosAppCategoriesCurrentSnapshot
      .where(ios_app_current_snapshot_id: snapshot.id)
      .where(kind: kind).destroy_all
end

def get_ios_expected_categories(ios_app)
  snapshot = ios_app.ios_app_current_snapshots.where(latest: true).first
  primary_category = IosAppCategoriesCurrentSnapshot
    .where(ios_app_current_snapshot_id: snapshot.id)
    .where(kind: kinds[:primary]).first.ios_app_category
  secondary_category = IosAppCategoriesCurrentSnapshot
    .where(ios_app_current_snapshot_id: snapshot.id)
    .where(kind: kinds[:secondary]).first.andand.ios_app_category
  return primary_category, secondary_category
end