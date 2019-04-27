describe AndroidLiveScanService do
  describe '.start_scan' do
    let(:android_app) { create(:android_app) }
    let(:described_method) { Proc.new { described_class.start_scan(android_app.id) } }
    before do
      allow_any_instance_of(AndroidLiveScanServiceWorker).to receive(:perform)
    end

    it 'creates an ApkSnapshotJob' do
      expect { described_method.call }.to change{ ApkSnapshotJob.count }.by(1)
    end
  end
end
