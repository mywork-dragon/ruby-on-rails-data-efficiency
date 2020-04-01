require 'spec_helper'

describe ApplicationHotStoreImportWorker do
  context 'only process relevan apps' do
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

    let!(:relevant_ios_apps) do
      create_list(:ios_app, 2,
        updated_at: Date.today,
        newest_ios_app_snapshot: create(:ios_app_snapshot, updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date)
      ) +
      create_list(:ios_app, 2,
        updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
        newest_ios_app_snapshot: create(:ios_app_snapshot, updated_at: Date.today)
      )
    end

    before do
      # Not relevant apps
      create_list(:android_app, 2,
        updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
        newest_android_app_snapshot: create(:android_app_snapshot, updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date)
      )
      create_list(:ios_app, 2,
        updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
        newest_ios_app_snapshot: create(:ios_app_snapshot, updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date)
      )
    end


    describe '.queue_android_apps' do
      it 'queue relevant apps' do
        expect_any_instance_of(described_class)
        .to receive(:perform)
        .with('android', relevant_android_apps.map(&:id))
        subject.queue_android_apps
      end
    end

    describe '.queue_ios_apps' do
      it 'queue relevant apps' do
        expect_any_instance_of(described_class)
        .to receive(:perform)
        .with('ios', relevant_ios_apps.map(&:id))
        subject.queue_ios_apps
      end
    end
  end

  context 'batch size' do
    let(:batch_size) { 2 }
    let(:number_of_batches) { 2 }

    before do
      create_list(:android_app, (batch_size * number_of_batches), # 500 + some in let! declarations => 2 batches
        updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
        newest_android_app_snapshot: create(:android_app_snapshot, updated_at: Date.today)
      )
      create_list(:ios_app, (batch_size * number_of_batches), # 500 + some in let! declarations => 2 batches
        updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
        newest_ios_app_snapshot: create(:ios_app_snapshot, updated_at: Date.today)
      )
      stub_const("#{described_class}::BATCH_SIZE", batch_size)
    end

    it 'queue relevant in batches' do
      expect(subject)
      .to receive(:delegate_perform).exactly(number_of_batches).times
      subject.queue_android_apps
    end

    it 'queue relevant in batches' do
      expect(subject)
      .to receive(:delegate_perform).exactly(number_of_batches).times
      subject.queue_ios_apps
    end
  end

end
