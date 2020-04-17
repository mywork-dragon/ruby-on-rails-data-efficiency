require 'spec_helper'

describe AppHotStore do
  let(:redis_cli) { Redis.new(:host => ENV['HOT_STORE_REDIS_URL'], :port => ENV['HOT_STORE_REDIS_PORT']) }

  before do
    redis_cli.flushall
  end

  describe ".write" do
    let(:platform) { 'android' }
    let!(:app_ids) { create_list(:android_app, 10).map(&:id) }
    let(:options)  { {} }
    let(:keys)     { app_ids.map{ |id| "app:#{platform}:#{id}"} }

    # This test relies on communicating with Redis. There might be a small delay.
    let(:margin_error) { 1 } # Seconds

    subject { described_class.new.write(platform, app_ids, options) }

    it 'writes the value to the hotstore with expiration' do
      subject
      sleep(3)
      keys.each do |k|
        delta = redis_cli.ttl(k) - HotStore::EXPIRATION_TIME_IN_SECS
        expect(delta <= margin_error).to be true
      end
    end
  end
end
