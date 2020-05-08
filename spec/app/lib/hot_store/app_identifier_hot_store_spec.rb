require 'spec_helper'

describe AppIdentifierHotStore do
  describe '.write' do

    let(:platform)       { 'android' }
    let(:type)           { 'ai' }
    let!(:android_app)   { create(:android_app) }
    let(:app_identifier) { android_app.app_identifier }
    let(:app_id)         { android_app.id  }
    let(:call_method)    { subject.write(platform, app_identifier, app_id) }
    let(:margin_error)   { 1 } # Seconds
    let(:key)            { "#{described_class::KEY_TYPE}:#{platform}:#{app_identifier}"}

    let(:redis_cli) do
       Redis.new(
         :host => ENV['HOT_STORE_REDIS_URL'],
         :port => ENV['HOT_STORE_REDIS_PORT']
       )
    end

    before { redis_cli.flushall }

    it { expect(call_method).to be_truthy }

    it 'sets the key in the hotstore' do
      call_method
      expect(redis_cli.get(key)).to eq(app_id.to_s)
    end

    it 'sets expiration time on the key' do
      call_method
      delta = redis_cli.ttl(key) - HotStore::EXPIRATION_TIME_IN_SECS
      #It should be the same EXPIRATION_TIME_IN_SECS (less a minimum margin)
      expect(delta <= margin_error).to be true
    end
  end
end
