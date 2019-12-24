require "rails_helper"

describe User, type: :model do
  context 'user creation callbacks' do
    subject { build(:user, id: 1) }

    before do
      allow(subject).to receive(:seed_timeline)
      allow(subject).to receive(:notify_slack)
      allow(subject).to receive(:notify_autopilot)
    end

    it 'notifies slack' do
      allow(subject).to receive(:notify_slack).and_call_original
      expect(subject).to receive(:notify_slack)
      expect(UserNotifyWorker).to receive(:perform_async).with(:slack, subject.id)
      expect(subject.save).to eq(true)
    end

    it 'notifies notifies autopilot' do
      allow(subject).to receive(:notify_autopilot).and_call_original
      expect(subject).to receive(:notify_autopilot)
      expect(UserNotifyWorker).to receive(:perform_async).with(:autopilot, subject.id)
      expect(subject.save).to eq(true)
    end


  end
end
