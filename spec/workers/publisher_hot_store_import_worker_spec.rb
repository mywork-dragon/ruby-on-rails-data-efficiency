require 'spec_helper'
require 'sidekiq/testing'

describe PublisherHotStoreImportWorker do
  # subject { described_class.perform_async(platform, publisher_id) }

  describe '.perform' do
    let(:num_of_records){ 5 }
    let(:platform)      { 'android' }
    let(:pub_hot_store) { instance_double(PublisherHotStore) }
    let(:call_method)   { num_of_records.times { |i| subject.perform(platform, i) } }

    before do
      allow(PublisherHotStore).to receive(:new) { pub_hot_store }
      allow(pub_hot_store).to receive(:write)
    end

    it 'wites to the hotstore' do
      expect(pub_hot_store)
        .to receive(:write)
        .with(platform, kind_of(Numeric))
        .exactly(num_of_records).times
      call_method
    end
  end

  describe '.queue_publishers' do

    let!(:relevant_ios_apps) do
      create_list(:ios_app, 2,
        updated_at: Date.today,
        ios_developer: build(:ios_developer, id: 998)
      )
    end

    let!(:relevant_android_apps) do
      create_list(:android_app, 2,
        updated_at: Date.today,
        android_developer: build(:android_developer, id: 999)
      )
    end

    before do
      allow(subject).to receive(:perform)

      # Not relevant apps. These apps where created and updated before relevance date.
      create_list(:android_app, 2,
        updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
        newest_android_app_snapshot: create(:android_app_snapshot, updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date),
        android_developer: build(:android_developer)
      )

      create_list(:ios_app, 2,
        updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
        newest_ios_app_snapshot: create(:ios_app_snapshot, updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date),
        ios_developer: build(:ios_developer)
      )
    end

    context 'ios publishers' do
      it 'queues only relevant apps' do
        assert_developer_for('ios')
        Sidekiq::Testing.inline!{ subject.queue_ios_publishers }
      end
    end

    context 'android publishers' do
      it 'queues only relevant apps' do
        assert_developer_for('android')
        Sidekiq::Testing.inline!{ subject.queue_android_publishers }
      end
    end

    def assert_developer_for(platform)
      expect(described_class)
        .to receive(:perform_async)
        .with(platform, be >= 998) # makes sure are the right developers
        .exactly(1).times #only one publisher with relevant apps
    end

  end
end
