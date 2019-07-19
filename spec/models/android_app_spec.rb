require "spec_helper"

describe AndroidApp, type: :model do

  context 'instance methods' do

    #included in MobileApp module. Extract into behave_like_a support file, later.
    describe '#sdk_history' do
      let(:apk_snapshot)  { build(:apk_snapshot, :scan_success, android_sdks: android_sdks) }
      let(:sdk)           { build(:android_sdk, name: sdk_name) }
      let(:android_sdks)  { [ sdk ] }
      let(:apk_snapshots) { [ apk_snapshot ]}
      let(:activities)    { subject[:activities] }
      let(:sdk_name)      { 'default' }

      context 'first time seen app' do
        describe 'installed_sdks' do
          let(:android_app)   { create(:android_app, apk_snapshots: apk_snapshots) }
          let(:sdk_name)      { 'installed_sdk' }
          let(:subject)       { android_app.sdk_history[:installed_sdks].first }

          it { expect(subject[:id]).to eq(sdk.id) }
          it { expect(subject[:name]).to eq(sdk.name) }
          it { expect(subject[:website]).to eq(sdk.website) }
          it { expect(subject[:favicon]).to eq(sdk.get_favicon) }
          it { expect(subject[:first_seen_date].to_formatted_s(:db)).to eq(apk_snapshot.first_valid_date.to_formatted_s(:db)) }
          it { expect(subject[:last_seen_date].to_formatted_s(:db)).to eq(apk_snapshot.good_as_of_date.to_formatted_s(:db)) }

          describe 'activities' do
            it { expect(activities.size).to eq(1) }
            it { expect(activities.first[:type]).to eq(:install) }
            it { expect(activities.first[:date].to_formatted_s(:db)).to eq(apk_snapshot.first_valid_date.to_formatted_s(:db)) }
          end
        end

        describe 'version varies with device' do
          let(:android_app)   { create(:android_app, apk_snapshots: apk_snapshots, newest_android_app_snapshot: naas) }
          let(:sdk_name)      { 'version_varies' }
          let(:subject)       { android_app.sdk_history[:installed_sdks].size }
          let(:naas)          { build(:android_app_snapshot, version: 'Varies with device') }

          it { expect(subject).to eq(1) }
        end
      end

      context 'already discovered app' do
        let(:android_app) do
          # good_as_of_date, first_valid_date set in callback
          Timecop.travel(1.month.ago) do
            create(:android_app, apk_snapshots: apk_snapshots)
          end
        end
        before { android_app.apk_snapshots << apk_snapshot_final }

        context 'uninstalled sdks' do
          let(:sdk_name)              { 'uninstalled_sdk' }
          let(:apk_snapshot_final)    { build(:apk_snapshot, :scan_success, android_sdks: []) }
          let(:subject)               { android_app.sdk_history[:uninstalled_sdks].first }

          it { expect(subject[:id]).to eq(sdk.id) }
          it { expect(subject[:name]).to eq(sdk.name) }
          it { expect(subject[:website]).to eq(sdk.website) }
          it { expect(subject[:favicon]).to eq(sdk.get_favicon) }
          it { expect(subject[:first_seen_date].to_formatted_s(:db)).to eq(apk_snapshot.first_valid_date.to_formatted_s(:db)) }
          it { expect(subject[:last_seen_date].to_formatted_s(:db)).to eq(apk_snapshot.good_as_of_date.to_formatted_s(:db)) }
          it { expect(subject[:first_unseen_date].to_formatted_s(:db)).to eq(apk_snapshot_final.first_valid_date.to_formatted_s(:db)) }

          describe 'activities' do
            it { expect(activities.size).to eq(2) }
            it { expect(activities.first[:type]).to eq(:install) }
            it { expect(activities.last[:type]).to eq(:uninstall) }
            it { expect(activities.first[:date].to_formatted_s(:db)).to eq(apk_snapshot.first_valid_date.to_formatted_s(:db)) }
            it { expect(activities.last[:date].to_formatted_s(:db)).to eq(apk_snapshot_final.first_valid_date.to_formatted_s(:db)) }
          end
        end

        context 'unchanged sdks' do
          let(:sdk_name)              { 'unchanged_sdk' }
          let(:apk_snapshot_final)    { build(:apk_snapshot, :scan_success, android_sdks: android_sdks) }
          let(:subject)               { android_app.sdk_history[:installed_sdks].first }

          it { expect(subject[:id]).to eq(sdk.id) }
          it { expect(subject[:name]).to eq(sdk.name) }
          it { expect(subject[:website]).to eq(sdk.website) }
          it { expect(subject[:favicon]).to eq(sdk.get_favicon) }
          it { expect(subject[:first_seen_date].to_formatted_s(:db)).to eq(apk_snapshot.first_valid_date.to_formatted_s(:db)) }
          it { expect(subject[:last_seen_date].to_formatted_s(:db)).to eq(apk_snapshot_final.good_as_of_date.to_formatted_s(:db)) }

          it { expect(subject[:first_unseen_date]).to be_nil }

          describe 'activities' do
            it { expect(activities.size).to eq(1) }
            it { expect(activities.first[:type]).to eq(:install) }
            it { expect(activities.first[:date].to_formatted_s(:db)).to eq(apk_snapshot.first_valid_date.to_formatted_s(:db)) }
          end
        end

        context 'reinstalled sdks' do
          let(:sdk_name)              { 'reinstalled_sdk' }
          let(:apk_snapshot_final)    { build(:apk_snapshot, :scan_success, android_sdks: android_sdks) }
          let(:apk_snapshot_middle)   { build(:apk_snapshot, :scan_success, android_sdks: []) }
          let(:subject)               { android_app.sdk_history[:installed_sdks].first }

          before do
            Timecop.travel(15.days.ago) do
              android_app.apk_snapshots << apk_snapshot_middle
            end
          end

          it { expect(subject[:id]).to eq(sdk.id) }
          it { expect(subject[:name]).to eq(sdk.name) }
          it { expect(subject[:website]).to eq(sdk.website) }
          it { expect(subject[:favicon]).to eq(sdk.get_favicon) }
          it { expect(subject[:first_seen_date].to_formatted_s(:db)).to eq(apk_snapshot.first_valid_date.to_formatted_s(:db)) }
          it { expect(subject[:last_seen_date].to_formatted_s(:db)).to eq(apk_snapshot_final.good_as_of_date.to_formatted_s(:db)) }
          it { expect(subject[:first_unseen_date]).to be_nil }

          context 'activities' do
            it { expect(activities.size).to eq(3) }
            it { expect(activities.first[:type]).to eq(:install) }
            it { expect(activities.second[:type]).to eq(:uninstall) }
            it { expect(activities.last[:type]).to eq(:install) }
            it { expect(activities.first[:date].to_formatted_s(:db)).to eq(apk_snapshot.first_valid_date.to_formatted_s(:db)) }
            it { expect(activities.second[:date].to_formatted_s(:db)).to eq(apk_snapshot_middle.first_valid_date.to_formatted_s(:db)) }
            it { expect(activities.last[:date].to_formatted_s(:db)).to eq(apk_snapshot_final.first_valid_date.to_formatted_s(:db)) }
          end
        end
      end

      context 'missing newest snapshot' do
        let(:android_app)    { create(:android_app, apk_snapshots: apk_snapshots, newest_apk_snapshot: nil) }
        let(:installed_sdks) { android_app.sdk_history[:installed_sdks] }
        let(:uninstalled_sdks) { android_app.sdk_history[:uninstalled_sdks] }
        let(:updated) { android_app.sdk_history[:updated] }

        it { expect(installed_sdks).to be_empty }
        it { expect(uninstalled_sdks).to be_empty }
        it { expect(updated).to be_nil }
      end
    end

    #included in MobileApp module. Extract into behave_like_a support file, later.
    describe '#filter_older_versions_from_android_apk_snapshots' do
      context 'only counts successful scans' do
        let(:snaps) { Array.new }
        let(:subject) { create(:android_app).filter_older_versions_from_android_apk_snapshots(snaps) }

        before do
          [:scan_failure, :scan_success, :invalidated, :scanning].each do |scan_status|
            snaps << build(:apk_snapshot, scan_status: scan_status)
          end
        end

        it { expect(subject.size).to eq(1) }
      end

      context 'skip versions already scanned' do
        let(:snap_1)  { Timecop.travel(12.months.ago) { build(:apk_snapshot, :scan_success, id: 1, version_code: 345) } }
        let(:snap_2)  { Timecop.travel(11.months.ago) { build(:apk_snapshot, :scan_success, id: 2, version_code: 300) } } #should skip
        let(:snap_3)  { Timecop.travel(10.months.ago) { build(:apk_snapshot, :scan_success, id: 3, version_code: 400) } }
        let(:snap_4)  { Timecop.travel(9.months.ago)  { build(:apk_snapshot, :scan_success, id: 4, version_code: 200) } } #should skip
        let(:snap_5)  { Timecop.travel(8.months.ago)  { build(:apk_snapshot, :scan_success, id: 5, version_code: 401) } }
        let(:snap_6)  { Timecop.travel(7.months.ago)  { build(:apk_snapshot, :scan_success, id: 6, version_code: 402) } }

        let(:snaps)   { (1..6).inject([]){ |memo, index| memo << eval("snap_#{index}") } }
        subject { create(:android_app).filter_older_versions_from_android_apk_snapshots(snaps)  }

        it { expect(subject.size).to eq(4)  }
        it { expect(subject).to include(snap_1)  }
        it { expect(subject).to include(snap_6)  }
        it { expect(subject).not_to include(snap_2)  }
        it { expect(subject).not_to include(snap_4)  }

        describe "dealing with nil" do
          let(:snaps)   { (1..9).inject([]){ |memo, index| memo << eval("snap_#{index}") } }
          let(:snap_7)  { Timecop.travel(6.months.ago)  { build(:apk_snapshot, :scan_success, id: 7, version_code: 403) } }
          let(:snap_8)  { Timecop.travel(5.months.ago)  { build(:apk_snapshot, :scan_success, id: 8, version_code: nil) } }
          let(:snap_9)  { Timecop.travel(4.months.ago)  { build(:apk_snapshot, :scan_success, id: 9, version_code: 404) } }

          it { expect(subject.size).to eq(7)  }
          it { expect(subject).to include(snap_8)  }

        end

      end

    end

    
  end
end
