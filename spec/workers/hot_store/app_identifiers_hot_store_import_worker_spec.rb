require 'spec_helper'
require 'sidekiq/testing'

describe AppIdentifiersHotStoreImportWorker do

  describe '.perform' do

    let(:map_array) do
      [
      # app identifiers    # app ids
        ['a',                 1],
        ['b',                 2],
        ['c',                 3],
        ['d',                 4]
      ]
    end

    let(:platform) { AndroidApp::PLATFORM_NAME }

    let(:call_method) { subject.perform(platform, map_array)}

    let(:double) { instance_double(AppIdentifierHotStore) }

    before do
      allow(AppIdentifierHotStore).to receive(:new).and_return(double)
    end


    it 'writes the map to the HotStore' do
      expect(double)
        .to receive(:write)
        .exactly(map_array.size)
        .times
        .with(platform, instance_of(String), instance_of(Integer))
      call_method
    end

  end

  describe '.import_android_map' do

    let!(:relevant_android_apps) do
      create_list(:android_app, 2,
        updated_at: Date.today,
        newest_android_app_snapshot: create(:android_app_snapshot, updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date)
      ) +
      create_list(:android_app, 2,
        updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
        newest_android_app_snapshot: create(:android_app_snapshot, updated_at: Date.today)
      )
    end

    it 'queue relevant apps' do

      apps_array = relevant_android_apps.map { |app| [app.app_identifier, app.id] }

      Sidekiq::Testing.inline! do
        expect_any_instance_of(described_class)
        .to receive(:perform)
        .with('android', apps_array)
        subject.import_android_map
      end
    end
  end

  describe '.import_ios_map' do
    xit 'queue relevant apps'
  end
end
