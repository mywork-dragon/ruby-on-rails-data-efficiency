describe AndroidLiveScanService do
  describe '.start_scan' do
    let(:android_app)      { create(:android_app) }
    let(:described_method) { Proc.new { described_class.start_scan(android_app.id) } }
    let(:redshift_logger)  { instance_double("RedshiftLogger") }
    subject { described_method.call }

    before do
      allow(RedshiftLogger).to receive(:new) { redshift_logger }
      allow(redshift_logger).to receive(:add)
      allow(redshift_logger).to receive(:send!)
    end

    context 'worker delegation' do
      before { allow(AndroidLiveScanServiceWorker).to receive(:new_job_for!) }

      it 'delegates work to AndroidLiveScanServiceWorker' do
        expect(AndroidLiveScanServiceWorker).to receive(:new_job_for!).with(android_app.id)
        subject
      end
    end


    it 'creates a log in redshift' do
      expect(described_class).to receive(:log_app_scan_status_to_redshift).with(android_app, :attempt, :live)
      subject
    end

    context 'error' do
      before do
        allow(redshift_logger).to receive(:send!).and_raise(StandardError.new("Some error"))
        allow(Bugsnag).to receive(:notify)
      end

      it 'reports error using Bugsnag' do
        expect(Bugsnag).to receive(:notify)
        subject
      end
    end
  end
end
