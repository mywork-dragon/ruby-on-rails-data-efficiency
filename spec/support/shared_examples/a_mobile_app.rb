RSpec.shared_examples 'a mobile app' do |platform, snap_prefix|

  context 'instance methods' do

    let(:mobile_app_key)            { "#{platform}_app".to_sym }
    let(:sdk_key)                   { "#{platform}_sdk".to_sym }
    let(:sdk_plural_key)            { "#{platform}_sdks".to_sym }
    let(:snapshot_key)              { "#{snap_prefix}_snapshot".to_sym }
    let(:newest_snapshot_key)       { "newest_#{snap_prefix}_snapshot".to_sym }
    let(:snapshot_plural_key)       { "#{snap_prefix}_snapshots".to_sym }
    let(:newest_store_snapshot_key) { "newest_#{platform}_app_snapshot".to_sym }
    let(:store_snapshot_key)        { "#{platform}_app_snapshot".to_sym }
    let(:snapshot_class)            { "#{snap_prefix.capitalize}Snapshot".constantize }
    let(:snapshots_scan_statuses)   {  snapshot_class.scan_statuses.keys.map(&:to_sym) }

    describe '#platform' do
      it { expect(subject.platform).to eq(platform) }
    end

    describe '#ios?' do
      it { expect(subject.ios?).to eq('ios' == platform) }
    end

    describe '#android?' do
      it { expect(subject.android?).to eq('android' == platform) }
    end

    describe '#mightysignal_public_page_link' do
      let(:identifier) { 123 }
      let(:mobile_app) { build(mobile_app_key.to_sym, app_identifier: identifier) }
      subject          { mobile_app.mightysignal_public_page_link }

      it { expect(subject).to match /https:\/\/mightysignal.com\/a\/#{mobile_app.store}\/#{identifier}/ }
    end

    describe '#sdk_history' do
      let(:snapshot)      { build(snapshot_key, :scan_success, sdk_plural_key => sdks) }
      let(:sdk)           { build(sdk_key, name: sdk_name) }
      let(:sdks)          { [ sdk ] }
      let(:snapshots)     { [ snapshot ] }
      let(:activities)    { subject[:activities] }
      let(:sdk_name)      { 'default' }

      context 'first time seen app' do
        describe 'installed_sdks' do
          let(:mobile_app)    { create(mobile_app_key, snapshot_plural_key => snapshots) }
          let(:sdk_name)      { 'installed_sdk' }
          let(:subject)       { mobile_app.sdk_history[:installed_sdks].first }

          it { expect(subject[:id]).to eq(sdk.id) }
          it { expect(subject[:name]).to eq(sdk.name) }
          it { expect(subject[:website]).to eq(sdk.website) }
          it { expect(subject[:favicon]).to eq(sdk.get_favicon) }
          it { expect(subject[:first_seen_date].to_formatted_s(:db)).to eq(snapshot.first_valid_date.to_formatted_s(:db)) }
          it { expect(subject[:last_seen_date].to_formatted_s(:db)).to eq(snapshot.good_as_of_date.to_formatted_s(:db)) }

          describe 'activities' do
            it { expect(activities.size).to eq(1) }
            it { expect(activities.first[:type]).to eq(:install) }
            it { expect(activities.first[:date].to_formatted_s(:db)).to eq(snapshot.first_valid_date.to_formatted_s(:db)) }
          end
        end

        describe 'version varies with device' do
          let(:mobile_app)   { create(mobile_app_key, snapshot_plural_key => snapshots, newest_store_snapshot_key => naas) }
          let(:sdk_name)      { 'version_varies' }
          let(:subject)       { mobile_app.sdk_history[:installed_sdks].size }
          let(:naas)          { build(store_snapshot_key, version: 'Varies with device') }

          it { expect(subject).to eq(1) }
        end
      end

      context 'already discovered app' do
        let(:mobile_app) do
          # good_as_of_date, first_valid_date set in callback
          Timecop.travel(1.month.ago) do
            create(mobile_app_key, snapshot_plural_key => snapshots)
          end
        end

        before { mobile_app.send(snapshot_plural_key) << snapshot_final }

        context 'uninstalled sdks' do
          let(:sdk_name)              { 'uninstalled_sdk' }
          let(:snapshot_final)        { build(snapshot_key, :scan_success, sdk_plural_key => []) }
          let(:subject)               { mobile_app.sdk_history[:uninstalled_sdks].first }

          it { expect(subject[:id]).to eq(sdk.id) }
          it { expect(subject[:name]).to eq(sdk.name) }
          it { expect(subject[:website]).to eq(sdk.website) }
          it { expect(subject[:favicon]).to eq(sdk.get_favicon) }
          it { expect(subject[:first_seen_date].to_formatted_s(:db)).to eq(snapshot.first_valid_date.to_formatted_s(:db)) }
          it { expect(subject[:last_seen_date].to_formatted_s(:db)).to eq(snapshot.good_as_of_date.to_formatted_s(:db)) }
          it { expect(subject[:first_unseen_date].to_formatted_s(:db)).to eq(snapshot_final.first_valid_date.to_formatted_s(:db)) }

          describe 'activities' do
            it { expect(activities.size).to eq(2) }
            it { expect(activities.first[:type]).to eq(:install) }
            it { expect(activities.last[:type]).to eq(:uninstall) }
            it { expect(activities.first[:date].to_formatted_s(:db)).to eq(snapshot.first_valid_date.to_formatted_s(:db)) }
            it { expect(activities.last[:date].to_formatted_s(:db)).to eq(snapshot_final.first_valid_date.to_formatted_s(:db)) }
          end
        end

        context 'unchanged sdks' do
          let(:sdk_name)              { 'unchanged_sdk' }
          let(:snapshot_final)    { build(snapshot_key, :scan_success, sdk_plural_key => sdks) }
          let(:subject)               { mobile_app.sdk_history[:installed_sdks].first }

          it { expect(subject[:id]).to eq(sdk.id) }
          it { expect(subject[:name]).to eq(sdk.name) }
          it { expect(subject[:website]).to eq(sdk.website) }
          it { expect(subject[:favicon]).to eq(sdk.get_favicon) }
          it { expect(subject[:first_seen_date].to_formatted_s(:db)).to eq(snapshot.first_valid_date.to_formatted_s(:db)) }
          it { expect(subject[:last_seen_date].to_formatted_s(:db)).to eq(snapshot_final.good_as_of_date.to_formatted_s(:db)) }

          it { expect(subject[:first_unseen_date]).to be_nil }

          describe 'activities' do
            it { expect(activities.size).to eq(1) }
            it { expect(activities.first[:type]).to eq(:install) }
            it { expect(activities.first[:date].to_formatted_s(:db)).to eq(snapshot.first_valid_date.to_formatted_s(:db)) }
          end
        end

        context 'reinstalled sdks' do
          let(:sdk_name)              { 'reinstalled_sdk' }
          let(:snapshot_final)        { build(snapshot_key, :scan_success, sdk_plural_key => sdks) }
          let(:snapshot_middle)       { build(snapshot_key, :scan_success, sdk_plural_key => []) }
          let(:subject)               { mobile_app.sdk_history[:installed_sdks].first }

          before do
            Timecop.travel(15.days.ago) do
              mobile_app.send(snapshot_plural_key) << snapshot_middle
            end
          end

          it { expect(subject[:id]).to eq(sdk.id) }
          it { expect(subject[:name]).to eq(sdk.name) }
          it { expect(subject[:website]).to eq(sdk.website) }
          it { expect(subject[:favicon]).to eq(sdk.get_favicon) }
          it { expect(subject[:first_seen_date].to_formatted_s(:db)).to eq(snapshot.first_valid_date.to_formatted_s(:db)) }
          it { expect(subject[:last_seen_date].to_formatted_s(:db)).to eq(snapshot_final.good_as_of_date.to_formatted_s(:db)) }
          it { expect(subject[:first_unseen_date]).to be_nil }

          context 'activities' do
            it { expect(activities.size).to eq(3) }
            it { expect(activities.first[:type]).to eq(:install) }
            it { expect(activities.second[:type]).to eq(:uninstall) }
            it { expect(activities.last[:type]).to eq(:install) }
            it { expect(activities.first[:date].to_formatted_s(:db)).to eq(snapshot.first_valid_date.to_formatted_s(:db)) }
            it { expect(activities.second[:date].to_formatted_s(:db)).to eq(snapshot_middle.first_valid_date.to_formatted_s(:db)) }
            it { expect(activities.last[:date].to_formatted_s(:db)).to eq(snapshot_final.first_valid_date.to_formatted_s(:db)) }
          end
        end
      end

      context 'missing newest snapshot' do
        let(:mobile_app)       { create(mobile_app_key, snapshot_plural_key => snapshots, newest_snapshot_key => nil) }
        let(:installed_sdks)   { mobile_app.sdk_history[:installed_sdks] }
        let(:uninstalled_sdks) { mobile_app.sdk_history[:uninstalled_sdks] }
        let(:updated)          { mobile_app.sdk_history[:updated] }

        it { expect(installed_sdks).to be_empty }
        it { expect(uninstalled_sdks).to be_empty }
        it { expect(updated).to be_nil }
      end
    end

    describe '#ad_attribution_sdks' do
      let!(:sdks)        { build_list(sdk_key, 3) }
      let(:snapshots)    { build_list(snapshot_key, 2, :scan_success, sdk_plural_key => sdks) }
      let(:mobile_app)   { create(mobile_app_key, snapshot_plural_key => snapshots) }
      let(:ad_sdks)      { sdks.first(2) }

      before { create(:tag, name: 'Ad Attribution', sdk_plural_key => ad_sdks) }

      subject { mobile_app.ad_attribution_sdks.map{ |sdk| sdk[:id] } }

      it { expect(subject).to eq(ad_sdks.map(&:id)) }
      it { expect(subject.size).to eq(2) }
    end
  end
end
