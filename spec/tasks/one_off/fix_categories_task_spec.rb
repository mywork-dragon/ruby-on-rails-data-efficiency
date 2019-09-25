require "rails_helper"
require '/varys/lib/tasks/one_off/fix_categories_task'

describe FixCategoriesTask do
  let(:kinds) { {primary: 0, secondary: 1} }
  let(:stream_name) { 'category_fix' }
  let(:firehose) { double(MightyAws::Firehose) }

  before :each do
    allow(MightyAws::Firehose).to receive(:new).and_return(firehose)
  end

  before { allow(MightyAws::Firehose).to receive_message_chain(:new, :send) }

  describe '.android_perform' do
    let(:android_category_data) { {category_id: 'CAT1', category_name: 'Cat1'} }

    context "udpate categories" do
      let(:category) { FactoryGirl.create(:android_app_category, name: 'Test', category_id: 'CAT1') }
      let(:newest_android_app_snapshot) { FactoryGirl.create(:android_app_snapshot, android_app_categories: [category]) }
      let(:android_app) { FactoryGirl.create(:android_app, newest_android_app_snapshot: newest_android_app_snapshot) }

      before :each do
        allow(GooglePlayService).to receive(:attributes).and_return(android_category_data)
        allow(firehose).to receive(:send).and_return(true)
        subject.android_perform(android_app)
      end

      it { expect(android_app.categories).to eq([category.name]) }
      it { expect(android_app.categories).to eq([AndroidAppCategory.find_by(category_id: android_category_data[:category_id]).name]) }
      it { expect(AndroidAppCategory.find_by(category_id: android_category_data[:category_id]).name).to eq(category.name) }
    end

    context "error streaming to firehose" do
      let(:android_app) { FactoryGirl.create(:android_app, newest_android_app_snapshot: nil) }

      before :each do
        allow(GooglePlayService).to receive(:attributes).and_return(android_category_data)

        subject.android_perform(android_app)
      end

      it 'android app no newest snaphot' do
        # If the app has no ios_app_current_snapshots means it has never been scanned
        # then we can't update the categories nor create new ones
        expect(android_app.categories).to eq([])
      end
    end
  end

  describe '.ios_perform' do
    let(:ios_category_data) { {categories: {primary: 'Cat1', secondary:['Cat2']}} }

    context "update categories" do
      let(:ios_app_current_snapshots) { FactoryGirl.create_list(:ios_app_current_snapshot, 3, latest: true) }
      let(:ios_app) { FactoryGirl.create(:ios_app, ios_app_current_snapshots: ios_app_current_snapshots) }

      before :each do
<<<<<<< HEAD:spec/tasks/one_off/fix_categories_task_spec.rb
        allow(firehose).to receive(:send).and_return(true)
=======
>>>>>>> master:spec/tasks/fix_categories_task_spec.rb
        allow(AppStoreService).to receive(:attributes).and_return(ios_category_data)
        subject.ios_perform(ios_app)
      end

      it { expect(ios_app.categories).to eq([ios_category_data[:categories][:primary]]) }
      it { expect(get_ios_expected_category(ios_app, kinds[:primary]).name).to eq(ios_category_data[:categories][:primary]) }
      it { expect(get_ios_expected_category(ios_app, kinds[:secondary]).name).to eq(ios_category_data[:categories][:secondary].first) }
      it { expect(ios_app.ios_app_current_snapshots.where(latest: true).count).to eq(1) }
    end

    describe "only one category attribute" do
      let(:ios_app) { FactoryGirl.create(:ios_app) }

      before :each do
        allow(AppStoreService).to receive(:attributes).and_return(ios_only_cat)
<<<<<<< HEAD:spec/tasks/one_off/fix_categories_task_spec.rb
        allow(firehose).to receive(:send).and_return(true)
=======
>>>>>>> master:spec/tasks/fix_categories_task_spec.rb
        subject.ios_perform(ios_app)
      end

      context "primary cat" do
        let(:ios_only_cat) { {categories: {primary: 'Cat1', secondary: []}} }
        it { expect(get_ios_expected_category(ios_app, kinds[:secondary])).to eq(nil) }
      end

      context "secondary cat" do
        let(:ios_only_cat) { {categories: {secondary: ['Cat2']}} }
        it { expect(get_ios_expected_category(ios_app, kinds[:primary])).to eq(nil) }
      end
    end

    context "error streaming to firehose" do
      let(:ios_app) { FactoryGirl.create(:ios_app, ios_app_current_snapshots: [])}

      before :each do
        allow(AppStoreService).to receive(:attributes).and_return(ios_category_data)
<<<<<<< HEAD:spec/tasks/one_off/fix_categories_task_spec.rb
        allow(firehose).to receive(:send).with(stream_name: stream_name, data: "ios, #{ios_app.id}, App has never been scanned")
=======
>>>>>>> master:spec/tasks/fix_categories_task_spec.rb
        subject.ios_perform(ios_app)
      end

      it 'process ios app no current snaphots' do
        # If the app has no ios_app_current_snapshots means it has never been scanned
        # then we can't update the categories nor create new ones
        expect(ios_app.categories).to eq([])
      end
    end

    describe "category current snapshot" do
      let(:ios_app_current_snapshot) {FactoryGirl.create(:ios_app_current_snapshot)}
      let(:ios_app) {FactoryGirl.create(:ios_app, ios_app_current_snapshots: [ios_app_current_snapshot])}

      before :each do
<<<<<<< HEAD:spec/tasks/one_off/fix_categories_task_spec.rb
        allow(firehose).to receive(:send).and_return(true)
=======
>>>>>>> master:spec/tasks/fix_categories_task_spec.rb
        allow(AppStoreService).to receive(:attributes).and_return(ios_category_data)
        subject.ios_perform(ios_app)
      end

      context "no primary and secondary category" do
        it {check_expect_category_current_snapshot(ios_app, ios_category_data, kinds)}
      end

      describe "no category" do
        let(:ios_app_category_current_snapshot) { FactoryGirl.create(:ios_app_categories_current_snapshot) }

        before :each do
          ios_app_category_current_snapshot.ios_app_current_snapshot = ios_app_current_snapshot
          ios_app_category_current_snapshot.kind = kind
          ios_app_category_current_snapshot.save!
        end

        context "primary" do
          let(:kind) { kinds[:primary] }
          it {check_expect_category_current_snapshot(ios_app, ios_category_data, kinds)}
        end

        context "secondary" do
          let(:kind) { kinds[:secondary] }
          it {check_expect_category_current_snapshot(ios_app, ios_category_data, kinds)}
        end
      end
    end
  end
end

def check_expect_category_current_snapshot(ios_app, ios_category_data, kinds)
  expect(ios_app.categories).to eq([ios_category_data[:categories][:primary]])
  expect(get_ios_expected_category(ios_app, kinds[:primary]).name).to eq(ios_category_data[:categories][:primary])
  expect(get_ios_expected_category(ios_app, kinds[:secondary]).name).to eq(ios_category_data[:categories][:secondary].first)
end

def get_ios_expected_category(ios_app, kind)
  snapshot = ios_app.ios_app_current_snapshots.where(latest: true).first
  category = IosAppCategoriesCurrentSnapshot
    .where(ios_app_current_snapshot_id: snapshot.id)
    .where(kind: kind).first.andand.ios_app_category
end
