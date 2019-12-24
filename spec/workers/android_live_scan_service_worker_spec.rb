require 'sidekiq/testing'

describe AndroidLiveScanServiceWorker do

  let(:job_double)       { instance_double(ApkSnapshotJob, id: 1) }
  let(:android_app)      { create(:android_app) }

  describe '.new_job_for!' do
    let(:described_method) { Proc.new { described_class.new_job_for!(android_app.id) } }
    subject { described_method.call }

    context 'creation of ApkSnapshotJob' do

      it { expect { subject }.to change{ ApkSnapshotJob.count }.by(1) }

      describe 'returns the job_id' do
        before { allow(ApkSnapshotJob).to receive(:create!) { job_double } }

        it { expect(subject).to eq job_double.id }
      end

      describe 'error on creation' do
        let(:redshift_logger)  { instance_double("RedshiftLogger") }
        let(:error_message)    { 'invalid' }

        before do
          allow(RedshiftLogger).to receive(:new) { redshift_logger }
          allow(redshift_logger).to receive(:send!)
          allow(ApkSnapshotJob).to receive(:create!).and_raise(StandardError, error_message)
        end

        it 'logs the error' do
          expect(described_class).to receive(:log_app_scan_status_to_redshift).with(android_app, :failed, :live, hash_including(error: error_message))
          subject
        end

      end
    end

    context 'queueing' do
      before { allow(ApkSnapshotJob).to receive(:create!) { job_double } }

      context 'inline' do
        let(:double) { instance_double(described_class) }

        before do
          allow(ENV).to receive(:[]).with(anything).and_call_original
          allow(ENV).to receive(:[]).with('JOBS_PERFORM_INLINE') { true }
          allow(described_class).to receive(:new) { double }
        end

        it 'performs the job' do
          expect(double).to receive(:perform)
          subject
        end
      end

      context 'async' do
        before do
          allow(ENV).to receive(:[]).with(anything).and_call_original
          allow(ENV).to receive(:[]).with('JOBS_PERFORM_INLINE') { false }
        end

        it 'enqueues the job' do
          expect(described_class).to receive(:perform_async)
          subject
        end

        it 'enqueues the job' do
          expect { described_class.perform_async(job_double.id, android_app.id) }
            .to change { described_class.jobs.size }.by(1)
        end
      end
    end
  end

  describe '#perform' do
    it "is skipped since it's a very simple method that calls two other methods." do
      # Methods tested as part of it_behaves_like
    end
  end
end
