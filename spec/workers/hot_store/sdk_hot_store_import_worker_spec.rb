require 'spec_helper'

describe SdkHotStoreImportWorker do
  describe '.perform' do
    let(:num_of_records){ 5 }
    let(:platform)      { 'android' }
    let(:sdk_hot_store) { instance_double(SdkHotStore) }
    let(:call_method)   { num_of_records.times { |i| subject.perform(platform, i) } }

    before do
      allow(SdkHotStore).to receive(:new) { sdk_hot_store }
      allow(sdk_hot_store).to receive(:write)
    end

    it 'wites to the hotstore' do
      expect(sdk_hot_store)
        .to receive(:write)
        .with(platform, kind_of(Numeric))
        .exactly(num_of_records).times
      call_method
    end
  end
end
