require 'sidekiq/testing'

describe SidekiqBatchQueueWorker do
  describe '#perform' do
    let(:number_of_jobs) { 100 }
    let(:job_id)         { 123 }
    let(:batch)          { Sidekiq::Batch.new }
    let(:clazz)          { class_name.constantize }
    let(:args) { number_of_jobs.times.with_index.map { |index| [job_id, index] } }
    let(:delegated_worker){ instance_double(clazz) }

    subject { described_class.perform_async(class_name, args, batch.bid) }

    before do
      allow(Sidekiq::Batch).to receive(:new).with(batch.bid).and_return(batch)
      allow(clazz).to receive(:new) { delegated_worker }
      allow(delegated_worker).to receive(:perform)
      allow(delegated_worker).to receive(:jid=)
    end

    context 'AndroidMassScanServiceWorker' do

      let(:class_name) { 'AndroidMassScanServiceWorker' }

      it do
        Sidekiq::Testing.inline! do
          expect(delegated_worker)
            .to receive(:perform)
            .with(job_id, instance_of(Integer))
            .exactly(number_of_jobs).times
          subject
        end
      end

    end
  end
end
