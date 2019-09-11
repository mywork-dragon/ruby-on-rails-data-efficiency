require "rails_helper"
require 'sidekiq/testing'

describe UserNotifyWorker do
  let(:peform_async_slack)     { described_class.perform_async(:slack, create(:user).id) }
  let(:peform_async_autopilot) { described_class.perform_async(:autopilot, create(:user).id) }

  before do
    # Catch the callback call
    allow_any_instance_of(User).to receive(:notify_slack)
    allow_any_instance_of(User).to receive(:notify_autopilot)
  end

  context 'queuing' do
    it 'queues slack notification' do
      expect { peform_async_slack }.to change(described_class.jobs, :size).by(1)
    end
    it 'queues autopilot notification' do
      expect { peform_async_autopilot }.to change(described_class.jobs, :size).by(1)
    end
  end

  context 'executing/performing' do
    it 'peforms slack' do
      Sidekiq::Testing.inline! do
        expect(Slackiq).to receive(:message)
        peform_async_slack
      end
    end

    it 'peforms autopilot' do
      Sidekiq::Testing.inline! do
        expect(AutopilotApi).to receive(:post_contact)
        peform_async_autopilot
      end
    end
  end
end
