require "rails_helper"
require '/varys/lib/tasks/one_off/fix_categories_task'

describe FixCategoriesTask do
  let(:android_app) { create(:android_app) }
  let(:ios_app) { create(:ios_app) }
  let(:android_method) { Proc.new { described_class.new.android_perform(android_app) } }
  let(:ios_method) { Proc.new { described_class.new.ios_perform(ios_app) } }

  before do
    allow_any_instance_of(MightyAws::Firehose).to receive(:send).and_return(true)
    allow_any_instance_of(AppHotStore).to receive(:write_attribute).and_return(true)
  end

  it 'update android app categories' do
    test_category_data = {category_id: 'CAT1', category_name: 'Cat1'}
    allow_any_instance_of(GooglePlayService).to receive(:attributes).and_return(test_category_data)

    android_method.call

    expect(android_app.categories).to eq([test_category_data[:category_name]])
  end

  it 'update ios app primary category' do
    test_category_data = {categories: {primary: 'Cat1', secondary:[]}}
    allow_any_instance_of(AppStoreService).to receive(:attributes).and_return(test_category_data)

    ios_method.call

    snapshot = ios_app.ios_app_current_snapshots.where(latest: true).first

    primary_category = IosAppCategoriesCurrentSnapshot
      .where(ios_app_current_snapshot_id: snapshot.id)
      .where(kind: 0).first.ios_app_category
    secondary_category = IosAppCategoriesCurrentSnapshot
      .where(ios_app_current_snapshot_id: snapshot.id)
      .where(kind: 1).first.andand.ios_app_category
    
    expect(ios_app.categories).to eq([test_category_data[:categories][:primary]])
    expect(primary_category.name).to eq(test_category_data[:categories][:primary])
    expect(secondary_category).to eq(nil)
  end

  it 'update ios app primary and secondary category' do
    test_category_data = {categories: {primary: 'Cat1', secondary:['Cat2']}}
    allow_any_instance_of(AppStoreService).to receive(:attributes).and_return(test_category_data)

    ios_method.call

    snapshot = ios_app.ios_app_current_snapshots.where(latest: true).first

    primary_category = IosAppCategoriesCurrentSnapshot
      .where(ios_app_current_snapshot_id: snapshot.id)
      .where(kind: 0).first.ios_app_category
    secondary_category = IosAppCategoriesCurrentSnapshot
      .where(ios_app_current_snapshot_id: snapshot.id)
      .where(kind: 1).first.ios_app_category

    expect(ios_app.categories).to eq([test_category_data[:categories][:primary]])
    expect(primary_category.name).to eq(test_category_data[:categories][:primary])
    expect(secondary_category.name).to eq(test_category_data[:categories][:secondary].first)
  end
end