module Android
  module Scanning
      # class Dummy; end
    describe Validator do

      dummy_class(:dummy) do
         def self.update_live_scan_job_status?; end
      end

      before do
        allow(ApkSnapshotScrapeFailure).to receive(:create!)
        allow(AndroidApp).to receive(:find).with(android_app.id) { android_app }
        allow(ApkSnapshotJob).to receive(:find).with(job_double.id) { job_double }
      end

      let(:validatable)   { dummy.extend(described_class) }
      let(:job_double)    { create(:apk_snapshot_job) }
      let(:android_app)   { create(:android_app) }
      let(:attrs)         { { some: :attr } }

      describe '.valid_job?' do

        subject { validatable.valid_job?(job_double.id, android_app.id) }

        context 'not avaliable' do
          before { allow(validatable).to receive(:pull_attributes).and_return(nil) }
          it { expect(subject).to be false }
        end

        context 'available' do
          before do
            allow(validatable).to receive(:pull_attributes).and_return(attrs)
          end

          context 'is paid' do
            let(:reason) { :paid }
            before { allow(validatable).to receive(:is_paid?) { true } }

            it { expect(subject).to be false }

            it 'logs result' do
              expect(dummy).to receive(:log_result).with(reason: reason)
              subject
            end

            it 'updates app' do
              expect(android_app).to receive(:update!).with(display_type: reason)
              subject
            end

            context 'live scan' do
              before { allow(validatable).to receive(:update_live_scan_job_status?) { true } }

              it 'updates apk_snapshot_job' do
                expect(job_double).to receive(:update!).with(ls_lookup_code: reason)
                subject
              end
            end

            context 'mass scan' do
              before { allow(validatable).to receive(:update_live_scan_job_status?).and_return(false) }

              it 'updates apk_snapshot_job' do
                expect(job_double).not_to receive(:update!).with(ls_lookup_code: reason)
                subject
              end
            end
          end

          context 'unchanged' do
            let(:reason) { :unchanged }

            before do
              allow(validatable).to receive(:nothing_to_update?).and_return(true)
              allow(validatable).to receive(:is_paid?).and_return(false)
            end

            it { expect(subject).to be false }

            it 'logs result' do
              expect(dummy).to receive(:log_result).with(reason: :unchanged_version)
              subject
            end

            it "updates app's newest_apk_snapshot" do
              expect(android_app).to receive_message_chain(:newest_apk_snapshot, :update!).with(good_as_of_date: instance_of(Time))
              subject
            end

            context 'live scan' do
              before { allow(validatable).to receive(:update_live_scan_job_status?) { true } }

              it 'updates apk_snapshot_job' do
                expect(job_double).to receive(:update!).with(ls_lookup_code: :unchanged)
                subject
              end
            end

            context 'live scan' do
              before { allow(validatable).to receive(:update_live_scan_job_status?) { false } }

              it 'updates apk_snapshot_job' do
                expect(job_double).not_to receive(:update!).with(ls_lookup_code: :unchanged)
                subject
              end
            end
          end
        end

        context 'errors' do

        end
      end

      describe '.pull_attributes' do
        before { allow(validatable).to receive(:android_app).and_return(android_app) }

        context 'success' do
          before { allow(GooglePlayDeviceApiService).to receive(:attributes).and_return(attrs) }

          subject { validatable.pull_attributes }

          it { expect(subject).to eq attrs }
        end

        context 'failure' do
          context 'bad Google Scrape' do
            before { allow(GooglePlayDeviceApiService).to receive(:attributes).and_raise(completar) }
          end
          context 'app not found'
          context 'app unavailable'
        end

      end
    end
  end
end
