require "spec_helper"

describe GooglePlaySnapshotModule do

  let(:instance) { Class.new.include(GooglePlaySnapshotModule).new }

  describe '.take_snapshot' do
    let(:android_app_snapshot_job_id) { 123 }
    let(:android_app) { create(:android_app, :without_newest_android_app_snapshot) }
    let(:snapshot_attributes) do
      YAML.load_file(
        Rails.root.join("spec/fixtures/android_app_snapshot_attributes.yml")
      ).deep_symbolize_keys
    end

    subject { instance.take_snapshot(android_app_snapshot_job_id, android_app.id, options) }

    before do
      allow(instance).to receive(:fetch_attributes_for).with(android_app, options) do
        snapshot_attributes
      end
      allow(instance).to receive(:delegate_perform)
    end


    context 'Live scan' do
      let(:options) do
        {
          create_developer: false,
          scrape_new_similar_apps: false,
          proxy_type: :general
        }
      end

      it { expect{subject}.to change{ AndroidAppCategory.count }.by(1) }
      it { expect{subject}.not_to change{ android_app.reload.android_developer }.from(nil) }
      it { expect(instance).not_to receive(:scrape_new_similar_apps); subject }


      it do
        expect {subject}
          .to change{ android_app.reload.newest_android_app_snapshot }
          .from(NilClass)
          .to(AndroidAppSnapshot)

        expect(
          android_app.reload
            .newest_android_app_snapshot
            .android_app_categories_snapshots
            .first
            .kind
        ).to eq 'primary'
      end

      context 'proxy_type' do
        before do
          allow(GooglePlayService).to receive(:single_app_details) { snapshot_attributes }
          allow(instance).to receive(:fetch_attributes_for).and_call_original
        end

        it do
          expect(instance)
          .to receive(:fetch_attributes_for)
          .with(android_app, hash_including(proxy_type: :general))
          subject
        end
      end
    end

    context 'Mass scan' do
      let(:options) do
        {
          create_developer: true,
          scrape_new_similar_apps: true,
          proxy_type: :temporary_proxies
        }
      end

      it do
        expect{subject}
          .to change{ android_app.reload.android_developer }
          .from(NilClass)
          .to(AndroidDeveloper)
      end

      it do
        expect(instance).to receive(:delegate_perform).with(Class, any_args)
        subject
      end

      it do
        expect(instance)
          .to receive(:delegate_perform)
          .with(GooglePlayDevelopersWorker, :create_by_android_app_id, android_app.id)
        subject
      end

      it { expect{subject}.to change{ AndroidAppCategory.count }.by(1) }
      it { expect(instance).to receive(:scrape_new_similar_apps); subject }

    end
  end
end
