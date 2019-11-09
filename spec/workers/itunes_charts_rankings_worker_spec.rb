require "rails_helper"
require 'sidekiq/testing'

describe ItunesChartsRankingsWorker do
  let(:storefront_id) { '1234' }

  subject { described_class.perform_async(storefront_id) }

  context 'queuing' do
    it 'queues jobs' do
      expect { subject }.to change(described_class.jobs, :size).by(1)
    end
  end

  context 'expecuting' do
    before do

      allow(ItunesTopChartsRankings).to receive(:request_for)  #test separately
    end

    it do
      expect(ItunesTopChartsRankings).to receive(:request_for)
      Sidekiq::Testing.inline!{ subject }
    end
  end
end
