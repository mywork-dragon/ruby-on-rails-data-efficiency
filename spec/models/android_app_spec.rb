require "spec_helper"

describe AndroidApp, type: :model do

  it_behaves_like 'a mobile app', 'android', 'apk'

  context 'instance methods' do

    #included in MobileApp module. Extract into behave_like_a support file, later.
    describe '#filter_older_versions_from_android_apk_snapshots' do
      context 'only counts successful scans' do
        let(:snaps) { Array.new }
        let(:subject) { create(:android_app).filter_older_versions_from_android_apk_snapshots(snaps) }

        before do
          [:scan_failure, :scan_success, :invalidated, :scanning].each do |scan_status|
            snaps << build(:apk_snapshot, scan_status: scan_status)
          end
        end

        it { expect(subject.size).to eq(1) }
      end

      context 'skip versions already scanned' do
        let(:snap_1)  { Timecop.travel(12.months.ago) { build(:apk_snapshot, :scan_success, id: 1, version_code: 345) } }
        let(:snap_2)  { Timecop.travel(11.months.ago) { build(:apk_snapshot, :scan_success, id: 2, version_code: 300) } } #should skip
        let(:snap_3)  { Timecop.travel(10.months.ago) { build(:apk_snapshot, :scan_success, id: 3, version_code: 400) } }
        let(:snap_4)  { Timecop.travel(9.months.ago)  { build(:apk_snapshot, :scan_success, id: 4, version_code: 200) } } #should skip
        let(:snap_5)  { Timecop.travel(8.months.ago)  { build(:apk_snapshot, :scan_success, id: 5, version_code: 401) } }
        let(:snap_6)  { Timecop.travel(7.months.ago)  { build(:apk_snapshot, :scan_success, id: 6, version_code: 402) } }

        let(:snaps)   { (1..6).inject([]){ |memo, index| memo << eval("snap_#{index}") } }
        subject { create(:android_app).filter_older_versions_from_android_apk_snapshots(snaps)  }

        it { expect(subject.size).to eq(4)  }
        it { expect(subject).to include(snap_1)  }
        it { expect(subject).to include(snap_6)  }
        it { expect(subject).not_to include(snap_2)  }
        it { expect(subject).not_to include(snap_4)  }

        describe "dealing with nil" do
          let(:snaps)   { (1..9).inject([]){ |memo, index| memo << eval("snap_#{index}") } }
          let(:snap_7)  { Timecop.travel(6.months.ago)  { build(:apk_snapshot, :scan_success, id: 7, version_code: 403) } }
          let(:snap_8)  { Timecop.travel(5.months.ago)  { build(:apk_snapshot, :scan_success, id: 8, version_code: nil) } }
          let(:snap_9)  { Timecop.travel(4.months.ago)  { build(:apk_snapshot, :scan_success, id: 9, version_code: 404) } }

          it { expect(subject.size).to eq(7)  }
          it { expect(subject).to include(snap_8)  }

        end

      end

    end

    describe '#store' do
      it { expect(subject.store).to eq('google-play') }
    end

    describe '#publisher' do
      let(:publisher) { build(:android_developer, id: 1234) }
      subject         { build(:android_app, android_developer: publisher) }

      it { expect(subject.publisher).to eq(publisher) }
    end
  end
end
