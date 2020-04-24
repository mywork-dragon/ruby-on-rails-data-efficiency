require 'spec_helper'
require 'sidekiq/testing'

describe PublisherHotStoreImportWorker do

  describe '.perform' do
    let(:num_of_records){ 5 }
    let(:ids_array)     { [ *1..num_of_records ] }
    let(:platform)      { 'android' }
    let(:pub_hot_store) { instance_double(PublisherHotStore) }
    let(:call_method)   { subject.perform(platform, ids_array)}

    before do
      allow(PublisherHotStore).to receive(:new) { pub_hot_store }
    end

    it 'wites to the hotstore' do
      expect(pub_hot_store)
        .to receive(:write)
        .with(platform, kind_of(Numeric))
        .exactly(num_of_records).times
      call_method
    end
  end

  context 'queuing' do

    describe '.queue_ios_publishers' do
      let(:ios_publisers_ids) { [888, 889] }

      let!(:relevant_ios_apps) do
        create_list(:ios_app, 2,
          updated_at: Date.today,
          ios_developer: build(:ios_developer, id: ios_publisers_ids.first)
        ) +
          create_list(:ios_app, 2,
            updated_at: Date.today,
            ios_developer: build(:ios_developer, id: ios_publisers_ids.last)
        )
      end

      before do
        create_list(:ios_app, 2,
          updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
          newest_ios_app_snapshot: create(:ios_app_snapshot, updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date),
          ios_developer: build(:ios_developer, id: 100)
        )
      end

      it 'queues only relevant publishers' do
        assert_developer_for(IosApp::PLATFORM_NAME, ios_publisers_ids)
        Sidekiq::Testing.inline!{ subject.queue_ios_publishers }
      end
    end


    describe '.queue_android_publishers' do

      let(:android_publisers_ids) { [998, 999] }

      let!(:relevant_android_apps) do
        create_list(:android_app, 2,
          updated_at: Date.today,
          android_developer: build(:android_developer, id: android_publisers_ids.first)
        ) +
          create_list(:android_app, 2,
            updated_at: Date.today,
            android_developer: build(:android_developer, id: android_publisers_ids.last)
        )
      end

      before do
        # Not relevant apps. These apps where created and updated before relevance date.
        create_list(:android_app, 2,
          updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
          newest_android_app_snapshot: create(:android_app_snapshot, updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date),
          android_developer: build(:android_developer, id: 200)
        )
      end

      it 'queues only relevant apps' do
        assert_developer_for(AndroidApp::PLATFORM_NAME, android_publisers_ids)
        Sidekiq::Testing.inline!{ subject.queue_android_publishers }
      end

    end

    def assert_developer_for(platform, expected_array)
      expect_any_instance_of(described_class)
      .to receive(:perform)
      .with(platform, expected_array)
    end

  end

end
