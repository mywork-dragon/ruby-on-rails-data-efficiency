require "spec_helper"

describe AndroidApp, type: :model do

  context 'instance methods' do
    let(:subject) { create(:android_app) }

    describe '#sdk_history' do
      let(:apk_snapshot)  { build(:apk_snapshot, :scan_success, android_sdks: android_sdks) }
      let(:sdk)           { build(:android_sdk, name: sdk_name) }
      let(:android_sdks)  { [ sdk ] }
      let(:apk_snapshots) { [ apk_snapshot ]}
      let(:activities)    { subject[:activities] }

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
    end
  end
end
