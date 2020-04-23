require 'spec_helper'
require 'sidekiq/testing'

describe AppIdentifiersHotStoreImportWorker do
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
      Sidekiq::Testing.inline! do
        expect_any_instance_of(described_class)
        .to receive(:perform)
        .with('android', relevant_android_apps.map(&:id))
        subject.import_android_map
      end
    end

  end

  describe '.import_ios_map' do
    xit 'queue relevant apps'
  end
end
