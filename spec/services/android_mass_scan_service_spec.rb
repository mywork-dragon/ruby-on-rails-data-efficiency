require 'sidekiq/testing'

describe AndroidMassScanService do
  describe '.run_recently_updated' do
    let(:delegated_worker_name)  { 'AndroidMassScanServiceWorker' }
    let(:job_double_id)    { '123' }
    let(:job_double)       { instance_double(ApkSnapshotJob, id: job_double_id) }

    before { allow(ApkSnapshotJob).to receive(:create!) { job_double } }

    subject { described_class.run_recently_updated(automated: automated) }

    context 'automated' do
      let(:automated) { true }

      describe 'queue the apps' do
        let(:slice_size) { 1_000 }
        let(:multiplier) { 2 }

        before(:all) do

          DatabaseCleaner.start
          # slice_size * multiplier = 2_000
          create_list(:android_app, 2_000, :recently_updated)
        end

        after(:all) do
          DatabaseCleaner.clean
        end

        before(:each) do
          SidekiqBatchQueueWorker.clear
        end

        it 'queues the right amount of jobs' do
          expect { subject }
          .to change { SidekiqBatchQueueWorker.jobs.size }.by(multiplier)
        end

        it 'pass the right params' do
          expect { subject }
          .to change {
            SidekiqBatchQueueWorker.jobs.present? &&
            SidekiqBatchQueueWorker.jobs.all? do |job|
              job['args'].first == delegated_worker_name &&
              job['args'].second.size == slice_size &&
              job['args'].last.present?
            end
          }.from( be false )
          .to( be true )
        end
      end

      pending 'not found recently_updated'

      context 'logging' do
        let(:a_few) { 3 } #we dont need many apps to test this part

        before { create_list(:android_app, a_few, :recently_updated) }

        it 'tries to send logs to redshift' do
          expect(described_class)
            .to receive(:log_multiple_app_scan_status_to_redshift)
            .with(array_including(AndroidApp.all.to_a), :attempt, :mass)
          subject
        end
      end

      context 'execution' do
        let(:a_few) { 3 } #we dont need many apps to test this part
        let(:delegated_worker_class)  { delegated_worker_name.constantize }
        let(:delegated_worker_double) { instance_double(delegated_worker_class) }

        before do
          create_list(:android_app, a_few, :recently_updated)
          allow(delegated_worker_class).to receive(:new) { delegated_worker_double }
          allow(delegated_worker_double).to receive(:perform)
          allow(delegated_worker_double).to receive(:jid=)
        end

        it 'finally calls the delegated_worker with the right args' do
          Sidekiq::Testing.inline! do
            expect(delegated_worker_double)
              .to receive(:perform)
              .with(job_double_id, instance_of(Integer))
              .exactly(a_few).times
            subject
          end
        end
      end
    end
  end
end
